extends Control

@onready var nome = null
@onready var victories:int = 0
@onready var button: Button = $Button

signal score
func _ready() -> void:
	pass
	$"..".create_form.connect(fill_form)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fill_form(player):
	nome = player["username"]
	$Label.text = nome
	$"..".create_form.disconnect(fill_form)
	$Button.size = $Label.get("size")
	Global.players_list.append(self)


func _on_button_pressed() -> void:
	victories += 1
	hide_score_button()
	position.y -= 75
	for game in Global.current_game:
		var player1 = Global.current_game[game]["player1"]
		var player2 = Global.current_game[game]["player2"]
		if player1["name"] == nome:
			var player_object = search_player(player2["name"])
			player_object.hide_score_button()
		if player2["name"] == nome:
			var player_object = search_player(player1["name"])
			player_object.hide_score_button()

func show_score_button():
	$Button.visible = true

func hide_score_button():
	$Button.visible = false
	
func search_player(player_name) -> Object:
	for player in Global.players_list:
		if player_name == player.nome:
			return player
	return null
