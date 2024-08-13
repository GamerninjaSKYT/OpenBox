class_name worldui
extends Control

@export var name_ui:Label
@export var world:String
@export var man:MenuManager

func Play():
	man.Load(world)
