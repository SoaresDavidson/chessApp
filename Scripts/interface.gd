extends Node2D

signal create_form

var distance = 25
func _ready() -> void:
	$webSocket.query.connect(new_form)


func new_form(form):
	if get_children()[-1] is not Button:
		var last_joined_player = get_children()[-1]
		var player_label = last_joined_player.get_node("Label")
		distance += player_label.get("size").x * 2 + 25
		print(player_label.get("size").x)
		
	$SpawnerComponent.spawn(Vector2(distance, 500), self)
	create_form.emit(form)


func _on_button_pressed() -> void:
	var players_list = get_children().slice(3) 
	$webSocket.send(players_list[0].get_node("Label").get("text"))
	#$webSocket.send() enviar alguma coisa que diga quem está pareado com quem
