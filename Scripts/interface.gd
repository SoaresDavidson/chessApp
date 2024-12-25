extends Node2D

signal create_form

var distance = 25
func _ready() -> void:
	$webSocket.query.connect(new_form)


func new_form(form):
	var player_object = get_children()[-1]
	if player_object is not Button:
		var last_joined_player = player_object
		var player_label = last_joined_player.get_node("Label")
		distance += player_label.get("size").x * 2 + 25
		
	$SpawnerComponent.spawn(Vector2(distance, 500), self)
	create_form.emit(form)


func _on_button_pressed() -> void:
	var players_list = get_children().slice(3) 
	
	var players_names:Array
	for player in players_list:
		players_names.append(player.get_node("Label").get("text"))
	players_names.shuffle()
	
	var games:Dictionary
	var players_len = len(players_names)
	var num = 1
	for index in range(0, players_len, 2):
		if players_len - index < 2:
			#fazer alguma coisa quando sobrar um jogador
			continue
		games["game"+str(num)] = {
			"PLayer1":{
				"Name":players_names[index],
				"Color" : "White",
				"Victorys": 0
				}
			,
			"PLayer2":{
				"Name":players_names[index+1],
				"Color" : "Black",
				"Victorys": 0
				}
		}
		num += 1
		
	var data_to_send = games
	var json_string = JSON.stringify(data_to_send)
	$webSocket.send(json_string)
