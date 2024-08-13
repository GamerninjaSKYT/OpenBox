class_name block
extends StaticBody2D
@export var id:String
@export var main_sprite:Sprite2D
@export var col:CollisionObject2D
@export var col_shape:CollisionShape2D
@export var destroyable:bool = false
@export var destroy_time:float = 1
@export var mining_tool_needed:String = ""
@export var need_tool_to_drop = false
var destroy_progress = 0
var mousehover = false
var chunkparent:chunk
var chunkpos:Vector2
@export var drop:item_instance = null
@export var inv:inventory = null
@export var inv_ui:TextureRect
@export var mining_progress_control:Control
var mining_progress:ProgressBar = null
@export var mining_progress_rot:Node2D
@export var makes_walkable = false
@export var can_walkable = false
@export var cant_be_destroyed_when_stood_on = false
@export var can_place_on = false
var made_walkable = false
@export var is_door = false
@export var cant_close_radius = 100
var open = false
@export var open_image:Texture2D
@export var closed_image:Texture2D
var built = false
@export var is_bed = false

func _ready():
	if mining_progress_control != null:
		mining_progress = mining_progress_control.get_child(0)
		mining_progress.max_value = destroy_time

func _process(delta):
	if built:
		get_tree().root.get_child(0).player.canbuild = true
		built = false
	if inv != null:
		inv.Updateslots()
	if mining_progress_control != null:
		if mining_progress_rot != null:
			mining_progress_rot.rotation = -rotation
		mining_progress.visible = (destroy_progress > 0)
		mining_progress.value = destroy_progress
	if mousehover:
		if get_tree().root.get_child(0).player.open_inv == null:
			OnMouseHover(delta)
	elif destroy_progress > 0 and destroyable:
		destroy_progress -= delta

func OnMouseHover(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and destroyable and !(cant_be_destroyed_when_stood_on and global_position.distance_to(get_tree().root.get_child(0).player.global_position) < 125):
		var on_top = true
		if can_place_on:
			for b in GetBlocksInRadius(50):
				if b.main_sprite.z_index > main_sprite.z_index:
					on_top = false
		if on_top and global_position.distance_to(get_tree().root.get_child(0).player.global_position) <= get_tree().root.get_child(0).player.reach:
			Mine(get_tree().root.get_child(0).player.inv.items[get_tree().root.get_child(0).player.inv.selected_hotbar_slot])
		elif  destroy_progress > 0:
			destroy_progress -= delta
	elif destroy_progress > 0:
		destroy_progress -= delta
	if Input.is_action_just_pressed("MR"):
		if global_position.distance_to(get_tree().root.get_child(0).player.global_position) <= get_tree().root.get_child(0).player.reach:
			if get_tree().root.get_child(0).player.open_inv == null:
				Use(true)

func Use(is_player_interaction):
	if inv != null and is_player_interaction:
		get_tree().root.get_child(0).player.open_inv = inv
		inv_ui.visible = true
	if is_door and (!is_player_interaction or global_position.distance_to(get_tree().root.get_child(0).player.global_position) > cant_close_radius or !open):
		OpenCloseDoor(!open)
	if is_bed and is_player_interaction:
		var m = get_tree().root.get_child(0)
		if !m.is_day:
			m.time += 24*60 - fmod(m.time, 60*24) + m.day_beginning_hour

func OpenCloseDoor(do_open:bool):
	open = do_open
	col.set_collision_layer_value(1,!open)
	col.set_collision_layer_value(2,open)
	if open:
		main_sprite.texture = open_image
	else:
		main_sprite.texture = closed_image

func Mine(mining_tool):
	var correct_tool = (mining_tool_needed == "")
	if mining_tool != null:
		mining_tool = mining_tool.item
		if mining_tool.mining_tool_type == mining_tool_needed and mining_tool_needed != "":
			destroy_progress += get_process_delta_time() * mining_tool.mining_multiplier - get_process_delta_time()
			correct_tool = true
		elif mining_tool_needed != "":
			correct_tool = false
	destroy_progress += get_process_delta_time()
	if destroy_progress >= destroy_time:
		Destroy(!(need_tool_to_drop and !correct_tool))

func _on_mouse_entered():
	mousehover = true

func _on_mouse_exited():
	mousehover = false
	
func Destroy(do_drop = true):
	if drop != null and do_drop:
		DropItem(drop)
	if inv != null:
		for i in inv.items:
			if i != null:
				DropItem(i)
	if makes_walkable:
		MakeWalkable(false)
	chunkparent.blocks.erase(self)
	queue_free()

func DropItem(item):
	var d = get_tree().root.get_child(0).itemdrop.instantiate()
	chunkparent.add_child(d)
	d.position = position
	d.item = item.duplicate()
	d.chunkparent = chunkparent
	d.chunkparent.drops.append(d)
	d.UpdateItemDrop()

func MakeWalkable(on = true):
	var blocks = GetBlocksInRadius(50)
	for b in blocks:
		if b.can_walkable:
			b.col.set_collision_layer_value(1,!on)
			b.col.set_collision_layer_value(2,on)
			b.made_walkable = on

func UpdateInChunkPos():
	chunkpos = get_tree().root.get_child(0).blockpos_to_inchunkpos(get_tree().root.get_child(0).pos_to_blockpos(global_position))
	return chunkpos

func GetBlocksInRadius(radius):
	var blocks = get_tree().root.get_child(0).GetBlocksInRadiusOnPos(radius, global_position)
	if blocks.has(self):
		blocks.erase(self)
	return blocks
