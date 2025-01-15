#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#include <quiche.h>

#define SERVER_IP "192.168.10.103" // Change to your server IP
#define SERVER_PORT 9090
#define MAX_DATAGRAM_SIZE 1350

int sock;
struct sockaddr_in server_addr;
uint8_t packet_buf[MAX_DATAGRAM_SIZE];
quiche_conn *conn;

// Function to create a UDP socket
int create_udp_socket() {
    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        perror("Failed to create socket");
        exit(1);
    }
    return sock;
}

// Initialize QUIC connection
quiche_conn* init_quic_conn(const char *server_name) {
    quiche_config *config = quiche_config_new(QUICHE_PROTOCOL_VERSION);
    if (!config) {
        fprintf(stderr, "Failed to create quiche config\n");
        exit(1);
    }

    quiche_config_set_application_protos(config,
        (uint8_t *) "\x05hq-29\x05hq-28\x08http/0.9", 15);
    quiche_config_verify_peer(config, false); // Disable certificate verification for simplicity

    uint8_t scid[QUICHE_MAX_CONN_ID_LEN];
    quiche_conn_id scid_struct = { .len = 16, .data = scid };
    quiche_conn *conn = quiche_connect(server_name, (const quiche_conn_id *)&scid_struct, config);

    if (!conn) {
        fprintf(stderr, "Failed to create quiche connection\n");
        exit(1);
    }

    return conn;
}

void send_quic_data(quiche_conn *conn, int sock, struct sockaddr_in *server_addr) {
    ssize_t written = quiche_conn_send(conn, packet_buf, sizeof(packet_buf));
    if (written < 0) {
        fprintf(stderr, "Failed to send data: %zd\n", written);
        exit(1);
    }

    ssize_t sent = sendto(sock, packet_buf, written, 0, (struct sockaddr *) server_addr, sizeof(*server_addr));
    if (sent < 0) {
        perror("sendto failed");
        exit(1);
    }
}

// Receive and process QUIC packets
void recv_quic_data(quiche_conn *conn, int sock) {
    struct sockaddr_in peer_addr;
    socklen_t peer_addr_len = sizeof(peer_addr);

    ssize_t recv_len = recvfrom(sock, packet_buf, sizeof(packet_buf), 0, (struct sockaddr *)&peer_addr, &peer_addr_len);
    if (recv_len < 0) {
        perror("recvfrom failed");
        exit(1);
    }

    ssize_t processed = quiche_conn_recv(conn, packet_buf, recv_len);
    if (processed < 0) {
        fprintf(stderr, "Failed to process received packet: %zd\n", processed);
        exit(1);
    }

    if (quiche_conn_is_established(conn)) {
        uint64_t stream_id;
        ssize_t read = quiche_conn_read(conn, &stream_id, packet_buf, sizeof(packet_buf));
        if (read > 0) {
            printf("Received: %.*s\n", (int) read, packet_buf);
        }
    }
}

int main() {
    sock = create_udp_socket();

    // Set up the server address
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(SERVER_PORT);
    if (inet_pton(AF_INET, SERVER_IP, &server_addr.sin_addr) <= 0) {
        perror("Invalid server IP address");
        exit(1);
    }

    // Initialize QUIC connection
    conn = init_quic_conn(SERVER_IP);

    // Send initial handshake packet
    send_quic_data(conn, sock, &server_addr);

    // Main loop to handle QUIC communication
    while (!quiche_conn_is_closed(conn)) {
        recv_quic_data(conn, sock);
        send_quic_data(conn, sock, &server_addr);
    }

    printf("Connection closed\n");

    close(sock);
    quiche_conn_free(conn);

    return 0;
}
