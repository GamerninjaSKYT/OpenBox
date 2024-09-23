class_name creature
extends CharacterBody2D

@export var id:String
@export var follows_player = false
@export var follow_range:float = 1000
@export var end_follow_range:float = 1500
var following_target = false
@export var damage_range = 100
@export var damage = 1
@export var damage_interval = 1
var damage_time = 0
@export var speed = 400
var player = null
var chunkparent:chunk

func _ready():
	if follows_player:
		player = get_tree().root.get_child(0).player
func _physics_process(delta):
	velocity = Vector2.ZERO
	if damage > 0:
		if global_position.distance_to(player.global_position) <= damage_range:
			if damage_time <= 0:
				damage_time = damage_interval
				player.hp -= damage
		damage_time -= delta
	if follows_player:
		if global_position.distance_to(player.global_position) <= follow_range:
			following_target = true
		if global_position.distance_to(player.global_position) >= end_follow_range:
			following_target = false
		if following_target:
			var direction = global_position.direction_to(player.global_position)
			velocity = direction * speed
	move_and_slide()

func ReparentChunk():
	chunkparent.blocks.erase(self)
	var c = get_tree().root.get_child(0).GetChunkFromChunkPos(get_tree().root.get_child(0).pos_to_chunkpos(global_position))
	reparent(c)
	c.blocks.append(self)
	chunkparent = c
