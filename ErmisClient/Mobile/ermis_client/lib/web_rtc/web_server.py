/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

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