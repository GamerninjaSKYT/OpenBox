class_name creature
extends CharacterBody2D

@export var id:String
@export var follows_player = false
@export var follow_range:float = 1000
@export_flags_2d_physics var sight_collision_mask
var last_target_pos = Vector2.ZERO
@export var damage_range = 100
@export var damage:float = 1
@export var damage_interval = 1
var damage_time = 0
@export var speed = 400
@export var sprite:Sprite2D
@export var sprite_front:Texture2D
@export var sprite_back:Texture2D
@export var sprite_left:Texture2D
@export var sprite_right:Texture2D
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
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(global_position, player.col.global_position, sight_collision_mask)
			var result = space_state.intersect_ray(query)
			if result:
				if result["collider"] == player:
					last_target_pos = player.global_position
		if last_target_pos != Vector2.ZERO:
			var direction = global_position.direction_to(last_target_pos)
			velocity = direction * speed
			if global_position.distance_to(last_target_pos) < 5:
				last_target_pos = Vector2.ZERO
	if velocity.x > abs(velocity.y):
		sprite.texture = sprite_right
	elif abs(velocity.x) < -velocity.y:
		sprite.texture = sprite_back
	elif -velocity.x > abs(velocity.y):
		sprite.texture = sprite_left
	else:
		sprite.texture = sprite_front
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
