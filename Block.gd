class_name block
extends StaticBody2D
@export var id = 0
@export var col:CollisionObject2D
@export var destroyable:bool = false
@export var destroy_time:float = 1
var destroy_progress = 0
var mousehover = false
var chunkparent:chunk
var chunkpos:Vector2
@export var drop:item_instance = null
@export var inv:inventory = null
@export var inv_ui:TextureRect
@export var mining_progress_control:Control

func _process(delta):
	if mining_progress_control != null:
		var mining_progress = mining_progress_control.get_child(0)
		mining_progress.visible = (destroy_progress > 0)
		mining_progress.max_value = destroy_time
		mining_progress.value = destroy_progress
	if mousehover:
		OnMouseHover(delta)
	elif destroy_progress > 0 and destroyable:
		destroy_progress -= delta

func OnMouseHover(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and destroyable:
		destroy_progress += get_process_delta_time()
		if destroy_progress >= destroy_time:
			Destroy()
	elif destroy_progress > 0:
		destroy_progress -= delta
	if Input.is_action_just_pressed("MR") and inv != null:
		if get_tree().root.get_child(0).player.open_inv == null:
			get_tree().root.get_child(0).player.open_inv = inv
			inv_ui.visible = true

func _on_mouse_entered():
	mousehover = true

func _on_mouse_exited():
	mousehover = false
	
func Destroy():
	if drop != null:
		var d = get_tree().root.get_child(0).itemdrop.instantiate()
		chunkparent.add_child(d)
		d.position = position
		d.item = drop.duplicate()
		d.chunkparent = chunkparent
		d.chunkparent.drops.append(d)
		d.UpdateItemDrop()
	chunkparent.blocks.erase(self)
	queue_free()

func UpdateInChunkPos():
	chunkpos = get_tree().root.get_child(0).blockpos_to_inchunkpos(get_tree().root.get_child(0).pos_to_blockpos(global_position))
	return chunkpos
