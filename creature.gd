class_name creature
extends CharacterBody2D

@export var id:String
@export var follows_player = false
@export var follow_range:float = 100
@export var speed = 400
var player = null
var chunkparent:chunk

func _ready():
	if follows_player:
		player = get_tree().root.get_child(0).player
func _physics_process(delta):
	if follows_player:
		if global_position.distance_to(player.global_position) <= follow_range:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * speed
			move_and_slide()

func ReparentChunk():
	chunkparent.blocks.erase(self)
	var c = get_tree().root.get_child(0).GetChunkFromChunkPos(get_tree().root.get_child(0).pos_to_chunkpos(global_position))
	reparent(c)
	c.blocks.append(self)
	chunkparent = c
