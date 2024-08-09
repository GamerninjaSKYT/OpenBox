extends Label

@export var splash:Label
@export var splashes:Array[String]

func _ready():
	splash.text = splashes.pick_random()
