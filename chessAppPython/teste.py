#!/usr/bin/env python
import asyncio
from websockets import serve
import websockets
from http.server import SimpleHTTPRequestHandler
from socketserver import ThreadingMixIn
from http.server import HTTPServer
import threading

# List of all connected WebSocket clients (for HTML and Godot)
clients = []

# WebSocket handler function
async def echo(websocket):
    # Register the client
    clients.append(websocket)
    try:
        # Listen for messages from any client (HTML or Godot)
        async for message in websocket:
            print(f"Received message: {message}")

            # Forward message to Godot (assuming Godot is listening)
            # You could store this message and trigger action based on its contents

            #(json.dumps(data) usar para enviar mensagens json
            for client in clients:
                if client != websocket:  # Don't send the message back to the same client
                    await client.send(message)  # Or any specific response

    except websockets.exceptions.ConnectionClosed:
        print("A client disconnected.")
    finally:
        clients.remove(websocket)


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