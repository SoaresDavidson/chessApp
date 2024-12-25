#!/usr/bin/env python
import asyncio
import json
from websockets import serve
import websockets
from http.server import SimpleHTTPRequestHandler
from socketserver import ThreadingMixIn
from http.server import HTTPServer
import threading

# WebSocket handler function
clients = {}  # Dictionary to store clients and their roles

async def echo(websocket):
    global clients
    try:
        async for message in websocket:
            print(f"Received: {message}")
            data = json.loads(message)

            # Handle client identification
            if "type" in data and data["type"] in ["html", "godot"]:
                clients[websocket] = data["type"]
                print(f"Client identified as: {data['type']}")
                continue
            
            # Forward messages based on type
            sender_type = clients.get(websocket)
            if sender_type == "html":
                # Send only to Godot
                for client, client_type in clients.items():
                    if client_type == "godot":
                        await client.send(message)
            elif sender_type == "godot":
                # Send only to HTML
                for client, client_type in clients.items():
                    if client_type == "html":
                        await client.send(message)
    except websockets.exceptions.ConnectionClosed:
        print("A client disconnected")
    finally:
        # Remove disconnected client
        if websocket in clients:
            del clients[websocket]


# HTTP server to serve HTML files
class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle HTTP requests in a separate thread."""
    daemon_threads = True

class HTTPHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.path = '/index.html'  # Default file to serve
        return super().do_GET()

async def run_http_server():
    server_address = ('0.0.0.0', 8080)  # HTTP server address
    httpd = ThreadedHTTPServer(server_address, HTTPHandler)
    print(f"Serving HTTP on {server_address[0]} port {server_address[1]}...")
    thread = threading.Thread(target=httpd.serve_forever)
    thread.start()

async def main():
    # Run HTTP server
    await run_http_server()
    # Start WebSocket server
    async with serve(echo, "localhost", 8765):
        print("WebSocket server running on ws://0.0.0.0:8765")
        await asyncio.get_running_loop().create_future()  # Run forever

# Run the event loop
asyncio.run(main())