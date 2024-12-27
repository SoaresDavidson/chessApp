extends Control
class_name Pessoa

@onready var nome = null
@onready var victories:int = 0
@onready var button: Button = $Button
@onready var opponent = null
signal score
signal player_free
func _ready() -> void:
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
	position.y -= 75
	hide_score_button()
	opponent.hide_score_button()
	change_player_list()
	var gameEnd = {"type": "gameEnd","winner":self.nome,"loser":opponent.nome}
	var json_string = JSON.stringify(gameEnd)
	$".."/webSocket.send(json_string)
	$"..".find_match()

func change_player_list() -> void:
	Global.in_game_players.erase(self)
	Global.off_game_players.append(self)
	Global.in_game_players.erase(opponent)
	Global.off_game_players.append(opponent)
	
func show_score_button():
	$Button.visible = true

func hide_score_button():
	$Button.visible = false
