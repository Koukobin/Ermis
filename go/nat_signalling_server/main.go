package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
	"github.com/pion/webrtc/v3"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func handleWebSocketConnection(w http.ResponseWriter, r *http.Request) {
	// Upgrade HTTP request to WebSocket
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}
	defer conn.Close()

	// Create WebRTC API instance
	api := webrtc.NewAPI(webrtc.WithMediaEngine(&webrtc.MediaEngine{}))

	// Create Peer Connection configuration
	peerConnection, err := api.NewPeerConnection(webrtc.Configuration{})
	if err != nil {
		log.Println("Error creating PeerConnection:", err)
		return
	}
	defer peerConnection.Close()

	// Handle signaling here - Example: Receive offer, set remote description, send back answer
	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			log.Println("Error reading WebSocket message:", err)
			break
		}

		// Example: handling offer or answer, signaling the WebRTC connection
		fmt.Println("Received message:", string(msg))

		// Handle WebRTC logic: Offer/Answer/ICE candidates here
	}
}

func main() {
	http.HandleFunc("/webrtc", handleWebSocketConnection)

	// Serve the HTTP server
	fmt.Println("Server listening on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
