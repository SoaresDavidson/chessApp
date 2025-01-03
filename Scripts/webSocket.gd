extends Node

# The URL we will connect to.
@export var websocket_url = "ws://localhost:8765"

# Our WebSocketClient instance.
var socket = WebSocketPeer.new()
signal received_message
func _ready():
	# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(2).timeout
		# Send data.
		var message = { "type": "godot", "id": "godot_client_1" }
		var json_string = JSON.stringify(message)
		socket.send_text(json_string)

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()
	
	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			#print("Got data from server: ", socket.get_packet().get_string_from_utf8())
			var message = get_message()
			received_message.emit(message)
			print("received message:"+message)

	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		print("por hoje é só pessoal")

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.
		
func get_message() -> Variant:
	if socket.get_available_packet_count() < 1:
		return null
	var package := socket.get_packet()
	if socket.was_string_packet():
		return package.get_string_from_utf8()
	return bytes_to_var(package)
	
func send(message) -> int:
	print("sended message:"+ message)
	if typeof(message) == TYPE_STRING:
		return socket.send_text(message)
	return socket.send(var_to_bytes(message))
