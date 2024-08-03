class_name Player
extends CharacterBody2D

@export var base_speed = 400  # base speed in pixels/sec
var last_chunkpos:Vector2
@export var image_front:Texture2D
@export var image_back:Texture2D
@export var image_side_left:Texture2D
@export var image_side_right:Texture2D
@export var sprite:Sprite2D
@export var buildzone:Area2D
@export var buildsprite:Sprite2D
@export var buildcan_color:Color
@export var buildcant_color:Color
@export var build_col:CollisionShape2D
@export var inv:inventory
@export var cursor_item:item_instance
@export var inv_ui:TextureRect
@export var open_inv:inventory = null
@export var extended_inv:Control

func _ready():
	inv_ui.visible = false

func _process(delta):
	inv.Updateslots()
	if inv.items[inv.selected_hotbar_slot] != null:
		if inv.items[inv.selected_hotbar_slot].item.build_id >= 0:
			if (UpdateBuildZone(inv.items[inv.selected_hotbar_slot].item)):
				if Input.is_action_just_pressed("MR") and open_inv == null and !inv.mouse_on_slot:
					Build()
		else:
			buildsprite.visible = false
	else:
		buildsprite.visible = false
	if cursor_item != null:
		Input.set_custom_mouse_cursor(cursor_item.item.image)
		if cursor_item.count < 1:
			cursor_item = null
	else:
		Input.set_custom_mouse_cursor(null)
	inv_ui.visible = (open_inv != null)
	extended_inv.visible = (open_inv == inv)
	if Input.is_action_just_pressed("inv"):
		if open_inv != null:
			open_inv.ui.visible = false
			open_inv = null
		else:
			open_inv = inv
	if Input.is_action_just_pressed("save"):
		get_tree().root.get_child(0)._save()
		get_tree().quit()
	if Input.is_action_just_pressed("drop"):
		if inv.items[inv.selected_hotbar_slot] != null:
			if !Input.is_action_pressed("shift"):
				DropItem(inv.items[inv.selected_hotbar_slot])
			else:
				DropItem(inv.items[inv.selected_hotbar_slot], inv.items[inv.selected_hotbar_slot].count)

func _physics_process(delta):
	if !inv_ui.visible:
		move() # move the player based on input
	
func move():
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * get_speed()
	if Input.is_action_pressed("left"):
		sprite.texture = image_side_left
	elif Input.is_action_pressed("right"):
		sprite.texture = image_side_right
	elif Input.is_action_pressed("down"):
		sprite.texture = image_front
	elif Input.is_action_pressed("up"):
		sprite.texture = image_back
	move_and_slide()

func UpdateBuildZone(item):
	buildsprite.visible = true
	buildzone.global_position = get_tree().root.get_child(0).position_snapped(get_global_mouse_position() + Vector2(64,64)) + item.build_offset
	buildsprite.texture = item.build_sprite
	buildsprite.position = item.build_sprite_offset
	build_col.scale = item.build_col_size
	if buildzone.get_overlapping_bodies().size() == 0:
		buildsprite.modulate = buildcan_color
		return true
	else:
		buildsprite.modulate = buildcant_color
		return false

func Build():
	inv.items[inv.selected_hotbar_slot].count -= 1
	var m = get_tree().root.get_child(0)
	var pos = m.pos_to_blockpos(buildzone.global_position - inv.items[inv.selected_hotbar_slot].item.build_offset)
	var c = m.GetChunkFromChunkPos(m.blockpos_to_chunkpos(pos))
	var b = m.AddBlockToChunk(c,m.objectlist[inv.items[inv.selected_hotbar_slot].item.build_id],0,0)
	b.global_position = pos*128
	b.UpdateInChunkPos()

func get_speed(): # apply speed modifiers here
	return base_speed

func DropItem(item, amount = 1):
	var d = get_tree().root.get_child(0).itemdrop.instantiate()
	get_tree().root.get_child(0).GetChunkFromChunkPos(get_tree().root.get_child(0).pos_to_chunkpos(position)).add_child(d)
	d.global_position = global_position
	d.item = item.duplicate()
	if amount > item.count:
		amount = item.count
	d.item.count = amount
	d.chunkparent = get_tree().root.get_child(0).GetChunkFromChunkPos(get_tree().root.get_child(0).pos_to_chunkpos(position))
	d.chunkparent.drops.append(d)
	d.UpdateItemDrop()
	item.count -= amount
