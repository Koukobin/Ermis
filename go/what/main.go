package main

import (
	"context"
	"crypto/tls"
	"fmt"
	"log"

	"github.com/quic-go/quic-go"
)

func main() {
	// Connect to the QUIC server
	addr := "192.168.10.103:9090"                      // Server address
	tlsConfig := &tls.Config{InsecureSkipVerify: true} // Skip cert verification for simplicity

	// Establish QUIC connection
	connection, err := quic.DialAddr(context.Background(), addr, tlsConfig, nil)
	if err != nil {
		log.Fatalf("Failed to dial QUIC server: %v", err)
	}
	fmt.Println("Connected to QUIC server")

	// Open a new stream
	stream, err := connection.OpenStreamSync(context.Background())
	if err != nil {
		log.Fatalf("Failed to open stream: %v", err)
	}

	// Send data to the server
	message := "Hello, QUIC server!"
	_, err = stream.Write([]byte(message))
	if err != nil {
		log.Fatalf("Failed to send data: %v", err)
	}

	// Receive the response
	buf := make([]byte, 1024)
	n, err := stream.Read(buf)
	if err != nil {
		log.Fatalf("Failed to read response: %v", err)
	}
	fmt.Printf("Received: %s\n", string(buf[:n]))
}
