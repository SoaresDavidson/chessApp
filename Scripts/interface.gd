extends Node2D

signal create_form

var distance = 25
var lines:Array = []
func _ready() -> void:
	#$webSocket.query.connect(new_form)
	$webSocket.query.connect(func(message):
		var parsed_message = JSON.parse_string(message)
		if parsed_message["type"] == "player":
			new_form(parsed_message)
		elif parsed_message["type"] == "gameEnd":
			pass
			#update_player()
		)

func _draw() -> void:
	if lines:
		draw_line(lines[0], lines[1], Color.ALICE_BLUE)
		print(lines)


func new_form(form):
	var player_object = get_children()[-1]
	if player_object is not Button:
		var last_joined_player = player_object
		var player_label = last_joined_player.get_node("Label")
		distance += player_label.get("size").x * 2 + 25
		
	$SpawnerComponent.spawn(Vector2(distance, 500), self)
	create_form.emit(form)


func _on_button_pressed() -> void:
	var players_list = Global.players_list
	players_list.shuffle()
	
	var game:Dictionary
	var players_len = len(players_list)
	var num = 1
	for index in range(0, players_len, 2):
		if players_len - index < 2:
			game["game"+str(num)] = {
				"player1":{
					"name": players_list[index].nome,
					"color" : "White",
					"victories": 0
					}
				,
				"player2": null
				}
			continue
		game["game"+str(num)] = {
			"player1":{
				"name": players_list[index].nome,
				"color" : "White",
				"victories": 0
				}
			,
			"player2":{
				"name": players_list[index+1].nome,
				"color" : "Black",
				"victories": 0
				}
		}
		num += 1
		
	var data_to_send = game
	var json_string = JSON.stringify(data_to_send)
	$webSocket.send(json_string)
	Global.current_game = game
	show_games(players_list)
	
func show_games(players_list:Array):
	var distance = 25
	for index in range(0, len(players_list), 2):
		var player1 = players_list[index]
		var player2 = players_list[index+1]
		player1.global_position.x = distance
		distance += player1.get_node("Label").get("size").x * 2 + 25
		player2.global_position.x = distance
		distance += player2.get_node("Label").get("size").x * 2 + 25
		lines = [Vector2(distance - player1.get_node("Label").get("size").x * 2 -75,550), Vector2(distance-150,550)]
		queue_redraw()

func update_player():
	pass
