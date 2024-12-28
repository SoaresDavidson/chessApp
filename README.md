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
- Manages client connections and forwards messages based on their type (`html` or `godot`).
- Adds clients to the `clients` dictionary when they identify themselves.
- Forwards messages only to the appropriate recipient type.

#### HTTP Server
- Serves the HTML front-end through the `/` endpoint.
- Defaults to serving `index.html` for root requests.
- Runs on port `8080`.

#### `main` Function
- Runs the HTTP server in a separate thread.
- Starts the WebSocket server on port `8765`.
- Uses `asyncio` to manage asynchronous tasks and keep the servers running.

### Execution Steps
1. **Run the Python Server**:
   Execute the Python script to start both the HTTP and WebSocket servers.

   ```bash
   python server.py
   ```

2. **Open the Web Application**:
   Navigate to `http://localhost:8080` in your browser to access the front-end.

3. **Connect to WebSocket**:
   - Click the "Connect" button to establish a WebSocket connection.
   - Interact with the UI to send messages and simulate game scenarios.

---

## How It Works

### Communication Flow
1. **Client Connection**:
   - The HTML client sends a message identifying itself as `html`.
   - Godot clients identify themselves as `godot`.

2. **Message Routing**:
   - HTML messages are forwarded only to `godot` clients.
   - Godot messages are forwarded only to `html` clients.

3. **Game Logic**:
   - The server processes JSON messages to trigger game events (e.g., start or end game).
   - Updates are sent to the appropriate clients in real-time.

### Error Handling
- Handles client disconnection gracefully by removing them from the `clients` dictionary.
- Logs parsing errors when invalid JSON is received.

---

## Conclusion
This system demonstrates:
- Real-time communication using WebSockets.
- Asynchronous server-side programming with `asyncio`.
- Integrating an HTTP server with a WebSocket server for a seamless front-end/back-end interaction.

For further development, you can:
- Enhance the game logic.
- Improve UI responsiveness.
- Add authentication or user sessions.

