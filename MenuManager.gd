class_name MenuManager
extends Node2D

@export var newgame_ui:TextureRect
@export var seed_ui:SpinBox

func _ready():
	newgame_ui.visible = false
	seed_ui.value = randi_range(0,2147480000)

func OpenCloseNewGame():
	newgame_ui.visible = !newgame_ui.visible
func Exit():
	get_tree().quit()
