extends Control

@onready var nome = null

func _ready() -> void:
	pass
	$"..".create_form.connect(fill_form)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fill_form(form):
	pass
	nome = form
	$Label.text = nome
	$"..".create_form.disconnect(fill_form)
