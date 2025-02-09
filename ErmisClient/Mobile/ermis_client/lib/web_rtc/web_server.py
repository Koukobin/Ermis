import asyncio
import websockets
import json

clients = {}

async def signaling_handler(websocket, path):
    try:
        async for message in websocket:
            data = json.loads(message)
            event = data.get("event")
            room_id = data.get("roomId")
            
            if event == "join":
                if room_id not in clients:
                    clients[room_id] = []
                clients[room_id].append(websocket)
                print(f"Client joined room {room_id}")
            
            elif event == "offer" or event == "answer" or event == "candidate":
                for client in clients.get(room_id, []):
                    if client != websocket:
                        await client.send(message)
    
    except websockets.exceptions.ConnectionClosed:
        print("Client disconnected")
    
    finally:
        for room, sockets in list(clients.items()):
            if websocket in sockets:
                sockets.remove(websocket)
                if not sockets:
                    del clients[room]

start_server = websockets.serve(signaling_handler, "192.168.10.103", 8085)

print("WebSocket signaling server started on ws://192.168.10.103:8085")
asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()