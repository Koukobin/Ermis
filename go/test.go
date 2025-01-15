package main

import (
	"context"
	"crypto/tls"
	"fmt"
	"log"

	"github.com/quic-go/quic-go"
)

func main() {
	fmt.Println("Initializing QUIC server...")

	// Start the QUIC server on UDP port 4242
	listener, err := quic.ListenAddr("192.168.10.103:9090", generateTLSConfig(), nil)
	if err != nil {
		log.Fatal("Failed to start QUIC listener:", err)
	}

	for {
		// Accept incoming QUIC connection
		ctx := context.Background()
		fmt.Println("Listening...")
		connection, err := listener.Accept(ctx)
		if err != nil {
			log.Println("Failed to accept connection:", err)
			continue
		}

		// Handle incoming streams in a separate goroutine
		go handleStream(connection)
	}
}

func generateTLSConfig() *tls.Config {
	// Generate or load a valid TLS config
	cert, err := tls.LoadX509KeyPair("/srv/Ermis-Server/Certificate/keystore.pem", "/srv/Ermis-Server/Certificate/server.key")
	if err != nil {
		log.Fatal("Failed to load TLS certificates:", err)
	}
	return &tls.Config{
		Certificates: []tls.Certificate{cert},
	}
}

func handleStream(connection quic.Connection) {
	// Accept the stream
	stream, err := connection.AcceptStream(context.Background())
	if err != nil {
		log.Println("Failed to accept stream:", err)
		return
	}

	// Receive data from the client
	buf := make([]byte, 1024)
	n, err := stream.Read(buf)
	if err != nil {
		log.Println("Failed to read from stream:", err)
		return
	}

	// For this example, just echo back the received data
	fmt.Printf("Received: %s\n", string(buf[:n]))

	// Send a response
	_, err = stream.Write([]byte("Hello from QUIC server"))
	if err != nil {
		log.Println("Failed to write to stream:", err)
	}
}
