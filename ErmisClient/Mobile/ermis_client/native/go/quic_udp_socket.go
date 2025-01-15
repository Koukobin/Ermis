package main

import (
	"context"
	"crypto/tls"
	"fmt"
	"log"

	"github.com/quic-go/quic-go"
)

var stream quic.Stream

func connect(socketAddr string) {
	tlsConfig := &tls.Config{InsecureSkipVerify: true} // Skip cert verification for simplicity

	connection, err := quic.DialAddr(context.Background(), socketAddr, tlsConfig, nil)
	if err != nil {
		log.Fatalf("Failed to dial QUIC server: %v", err)
	}
	fmt.Println("Connected to QUIC server")

	// Open a new stream
	stream, err = connection.OpenStreamSync(context.Background())
	if err != nil {
		log.Fatalf("Failed to open stream: %v", err)
	}
}

func sendString(message string) {
	sendBytes([]byte(message))
}

func sendBytes(message []byte) {
	_, err := stream.Write(message)
	if err != nil {
		log.Fatalf("Failed to send data: %v", err)
	}
}

func main() {
	// Connect to the QUIC server
	addr := "192.168.10.103:9090"
	connect(addr)

	sendString("hi")

	// Receive the response
	buf := make([]byte, 1024)
	n, err := stream.Read(buf)
	if err != nil {
		log.Fatalf("Failed to read response: %v", err)
	}
	fmt.Printf("Received: %s\n", string(buf[:n]))
}
