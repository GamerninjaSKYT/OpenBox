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
var lastchunk = Vector2.ZERO
@export var hp:float = 10
@export var maxhp:float = 10
var m:WorldManager
@export var spriteanim:AnimationPlayer
@export var despawns = true #set to false for animals

func _ready():
	m = get_tree().root.get_child(0)
	if follows_player:
		player = get_tree().root.get_child(0).player
func _process(delta):
	if lastchunk != m.pos_to_chunkpos(global_position):
		lastchunk = m.pos_to_chunkpos(global_position)
		ReparentChunk()
	if hp > maxhp:
		hp = maxhp
	if hp <= 0:
		Destroy()
	if damage > 0:
		if global_position.distance_to(player.global_position) <= damage_range:
			if damage_time <= 0:
				damage_time = damage_interval
				player.Damage(damage)
		damage_time -= delta
func _physics_process(delta):
	velocity = Vector2.ZERO
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
	get_tree().root.get_child(0).LoadChunk(get_tree().root.get_child(0).pos_to_chunkpos(global_position))
	chunkparent.creatures.erase(self)
	var c = get_tree().root.get_child(0).GetChunkFromChunkPos(get_tree().root.get_child(0).pos_to_chunkpos(global_position))
	reparent(c)
	c.creatures.append(self)
	chunkparent = c

func Damage(damage):
	hp -= damage
	spriteanim.play("hit")

func Destroy():
	chunkparent.creatures.erase(self)
	queue_free()
