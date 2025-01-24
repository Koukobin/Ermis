package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true // Allow all connections
	},
}

type Peer struct {
	Connection *websocket.Conn
	RoomID     string
}

var peers = make(map[string][]*Peer) // RoomID -> List of peers

func main() {
	http.HandleFunc("/ws", handleWebSocket)
	http.ListenAndServe(":8085", nil)
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("Error upgrading connection:", err)
		return
	}
	defer conn.Close()

	// Handle messages from the client
	for {
		messageType, p, err := conn.ReadMessage()
		if err != nil {
			log.Println("Error reading message:", err)
			return
		}

		var message map[string]interface{}
		if err = json.Unmarshal(p, &message); err != nil {
			log.Println("Error unmarshalling message:", err)
			continue
		}

		handleSignalingMessage(conn, message)

		// Broadcast message to all peers in the room
		var roomID string = message["roomId"].(string)
		if roomPeers, ok := peers[roomID]; ok {
			fmt.Println("Received Offer")
			// Store the offer temporarily and forward it to the other peer.
			// You might want to send it back to the same peer or broadcast it.
			for _, peer := range roomPeers {
				if peer.Connection != conn {
					if err := peer.Connection.WriteMessage(messageType, p); err != nil {
						log.Println("Error sending message:", err)
					}
				}
			}
		} else {
			fmt.Println("Creating new room entry...");
			// If the room does not exist, create a new room entry
			peers[roomID] = append(peers[roomID], &Peer{
				Connection: conn,
				RoomID:     roomID,
			})
			fmt.Println(roomID)
		}
	}
}

// Handle incoming signaling message
func handleSignalingMessage(conn *websocket.Conn, message map[string]interface{}) {
	// For example: you can handle SDP offer, answer, and ICE candidates here
	fmt.Println("hello world")
	fmt.Println(message["roomId"])
	switch message["type"] {
	case "offer":
		fmt.Println("Received Offer")
		// Process the offer and forward it to other peers
		// Send an answer back or relay the offer to other peers
	case "answer":
		fmt.Println("Received Answer")
		// Process the answer from peer
	case "candidate":
		fmt.Println("Received ICE Candidate")
		// Relay ICE candidate to other peers
		fmt.Println("Received ICE Candidate")
		// Forward the ICE candidate to the other peers in the room
	}
}
