extends Node2D

signal create_form
var distance = 25
var lines:Array = []
func _ready() -> void:
	#$webSocket.query.connect(new_form)
	$webSocket.received_message.connect(func(message):
		var parsed_message = JSON.parse_string(message)
		if parsed_message["type"] == "player":
			new_form(parsed_message)
		elif parsed_message["type"] == "gameEnd":
			update_player(parsed_message)
		)
	

func new_form(form):
	if Global.players_list:
		var player_object = Global.players_list[-1]
		var last_joined_player = player_object
		var player_label = last_joined_player.get_node("Label")
		distance += player_label.get("size").x * 2 + 25
		
	$SpawnerComponent.spawn(Vector2(distance, 500), self)
	create_form.emit(form)


func _on_button_pressed() -> void: #começar jogo
	var players_list = Global.players_list
	players_list.shuffle()
	
	var game:Dictionary
	var players_len = len(players_list)
	var num = 1
	for index in range(0, players_len, 2):
		var player1 = players_list[index]
		var player2 = null
		if players_len - index < 2:
			game["game"+str(num)] = {
				"player1":{
					"name": player1.nome,
					"color" : "White",
					"victories": 0
					}
				,
				"player2": null,
				"type":"gameStart"
				}
			Global.off_game_players.append(player1)
		else:
			player2 = players_list[index+1]
			game["game"+str(num)] = {
				"player1":{
					"name": player1.nome,
					"color" : "White",
					"victories": 0
					}
				,
				"player2":{
					"name": player2.nome,
					"color" : "Black",
					"victories": 0
					},
				"type":"gameStart"
			}
			var data_to_send = game["game"+str(num)]
			var json_string = JSON.stringify(data_to_send)
			$webSocket.send(json_string)
			player1.opponent = player2
			player2.opponent = player1
			Global.in_game_players.append(player1)
			Global.in_game_players.append(player2)
			num += 1
	Global.current_game = game
	show_games(players_list)
	#$Button.visible = false
	
func show_games(players_list:Array):
	var distance = 25
	for index in range(0, len(players_list), 2):
		var player1 = players_list[index]
		player1.global_position.x = distance
		distance += player1.get_node("Label").get("size").x * 2 + 25
		if len(players_list) <= 1: return
		var player2 = players_list[index+1]
		player2.global_position.x = distance
		distance += player2.get_node("Label").get("size").x * 2 + 25

func update_player(message):
	var player1_name = message["username"]
	var player2_name = message["opponent"]
	var player1_object = search_player(player1_name)
	var player2_object = search_player(player2_name)
	player1_object.show_score_button()
	player2_object.show_score_button()

func search_player(player_name) -> Object:
	for player in Global.players_list:
		if player_name == player.nome:
			return player
	return null

func find_match():
	for player in Global.off_game_players:
		for player2 in Global.off_game_players:
			if player.victories == player2.victories and player != player2:
				create_match(player, player2)
				Global.off_game_players.erase(player)
				Global.off_game_players.erase(player2)
			
func create_match(player1:Pessoa, player2:Pessoa):
	var game:Dictionary
	game = {"player1":{
			"name": player1.nome,
			"color" : "White",
			"victories": player1.victories
			},
		"player2":{
			"name": player2.nome,
			"color" : "Black",
			"victories": player2.victories
			},
		"type":"gameStart"
	}
	player1.opponent = player2
	player2.opponent = player1
	var data_to_send = game
	var json_string = JSON.stringify(data_to_send)
	$webSocket.send(json_string)
