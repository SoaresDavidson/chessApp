# WebSocket Game Communication System

## Overview
This project consists of an HTML front-end and a Python back-end. It establishes a communication system using WebSockets for real-time data exchange between clients (a web browser and a Godot engine). The Python back-end serves as both an HTTP server to deliver the web application and a WebSocket server to handle communication.

---

## Front-End (HTML + JavaScript)

### Description
The front-end is a basic web interface that:
- Connects to a WebSocket server.
- Sends and receives messages in JSON format.
- Displays a waiting room or game result modal based on the server's response.

### Key Features

1. **WebSocket Connection**:
   - A WebSocket connection is established with the server upon clicking the "Connect" button.
   - Communication is done in real-time using JSON messages.

2. **User Interaction**:
   - Users can input their username and send it to the server.
   - Buttons allow for sending predefined messages or game results to the server.

3. **Dynamic UI Updates**:
   - Displays a waiting room modal during processing.
   - Shows game information, including roles and victories.
   - Handles game start and end scenarios.

### Files
- `index.html`: Contains the structure and logic for interacting with the WebSocket server.

### Key Snippets

#### WebSocket Connection
```javascript
socket = new WebSocket('ws://localhost:8765');

socket.onopen = () => {
    hideWaitingRoom();
    document.getElementById('output').innerHTML += '<p>Connected to server</p>';
    const clientId = 'html_client_' + Date.now();
    socket.send(JSON.stringify({ type: 'html', id: clientId }));
};

socket.onmessage = (event) => {
    try { 
        const data = JSON.parse(event.data);
        if (data["type"] === "gameStart") {
            startGame(data);
        }
        if (data["type"] === "gameEnd") {
            endGame(data);
        }
    } catch (e) {
        console.error("Error parsing JSON:", e);
        document.getElementById("output").innerHTML += `<p>Invalid JSON received: ${event.data}</p>`;
    }
};
```

#### Game Start Handling
```javascript
function startGame(data) {
    try {
        if (data) {
            const player1 = data["player1"];
            const player2 = data["player2"];
            let userInfo = null;
            let opponentInfo = null;

            if (player1 && player1["name"] === username) {
                userInfo = { name: player1["name"], role: player1["color"], victories: player1["victories"] };
                opponentInfo = player2
                    ? { name: player2["name"], role: player2["color"], victories: player2["victories"] }
                    : null;
            } else if (player2 && player2["name"] === username) {
                userInfo = { name: player2["name"], role: player2["color"], victories: player2["victories"] };
                opponentInfo = player1
                    ? { name: player1["name"], role: player1["color"], victories: player1["victories"] }
                    : null;
            }
        }

        if (userInfo) {
            document.getElementById("output").innerHTML = `
                <p>Welcome, ${userInfo.name}!</p>
                <p>Your role is: ${userInfo.role}</p>
                <p>Victories: ${userInfo.victories}</p>
            `;
            if (opponentInfo) {
                document.getElementById("output").innerHTML += `<p>Opponent: ${opponentInfo.name} (${opponentInfo.role}, ${opponentInfo.victories} victories)</p>`;
            } else {
                showWaitingRoom("Unfortunately, there wasn't an opponent left for you. Wait until the next round.");
                return;
            }
        } else {
            document.getElementById("output").innerHTML = `
                <p>Your name was not found in the data.</p>
                <p>Received data: ${JSON.stringify(data)}</p>
            `;
        }
        if (opponentInfo) {
            hideWaitingRoom();
        }
    } catch (e) {
        console.error("Error reading JSON:", e);
        document.getElementById("output").innerHTML += `<p>Invalid JSON received: ${event.data}</p>`;
    }
}
```

---

## Back-End (Python)

### Description
The back-end is a combination of an HTTP server and a WebSocket server. It uses the `asyncio` library for handling asynchronous operations and `websockets` for managing WebSocket communication.

### Key Features

1. **HTTP Server**:
   - Serves the HTML files to the client.
   - Uses `http.server.SimpleHTTPRequestHandler` to handle HTTP requests.
   - Runs in a separate thread using the `ThreadingMixIn` class from the `socketserver` module.

2. **WebSocket Server**:
   - Handles real-time communication between the front-end (HTML) and Godot clients.
   - Identifies clients by type (`html` or `godot`) and routes messages accordingly.

3. **Client Management**:
   - Maintains a dictionary of connected clients and their types.
   - Forwards messages between HTML and Godot clients based on their type.

### Key Python Modules

#### 1. **`asyncio`**
   - Provides the foundation for asynchronous programming.
   - Used to manage the WebSocket server and integrate the HTTP server.

#### 2. **`websockets`**
   - Handles WebSocket communication between the server and connected clients.
   - Supports sending and receiving messages asynchronously.

#### 3. **`http.server`**
   - `SimpleHTTPRequestHandler`: Serves static files (e.g., HTML, CSS, JavaScript).
   - Used to provide the front-end to the browser.

#### 4. **`socketserver`**
   - `ThreadingMixIn`: Allows the HTTP server to handle requests in separate threads.
   - Ensures the server remains responsive during file serving.

#### 5. **`threading`**
   - Runs the HTTP server in a separate thread to operate alongside the WebSocket server.

### Code Explanation

#### WebSocket Handler
```python
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
```

#### HTTP Server
```python
class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle HTTP requests in a separate thread."""
    daemon_threads = True

class HTTPHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.path = '/index.html'  # Default file to serve
        return super().do_GET()
```

#### `main` Function
```python
async def main():
    # Run HTTP server
    await run_http_server()
    # Start WebSocket server
    async with websockets.serve(echo, "localhost", 8765):
        print("WebSocket server running on ws://0.0.0.0:8765")
        await asyncio.get_running_loop().create_future()  # Run forever

asyncio.run(main())
```


