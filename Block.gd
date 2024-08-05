class_name block
extends StaticBody2D
@export var id = 0
@export var col:CollisionObject2D
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

func _process(delta):
	if inv != null:
		inv.Updateslots()
	if mining_progress_control != null:
		var mining_progress = mining_progress_control.get_child(0)
		mining_progress.rotation = -rotation
		mining_progress.visible = (destroy_progress > 0)
		mining_progress.max_value = destroy_time
		mining_progress.value = destroy_progress
	if mousehover:
		if get_tree().root.get_child(0).player.open_inv == null:
			OnMouseHover(delta)
	elif destroy_progress > 0 and destroyable:
		destroy_progress -= delta

func OnMouseHover(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and destroyable:
		var mining_tool = get_tree().root.get_child(0).player.inv.items[get_tree().root.get_child(0).player.inv.selected_hotbar_slot]
		var correct_tool = (mining_tool_needed == "")
		if mining_tool != null:
			mining_tool = mining_tool.item
			if mining_tool.mining_tool_type == mining_tool_needed and mining_tool_needed != "":
				destroy_progress += delta * mining_tool.mining_multiplier - delta
				correct_tool = true
			elif mining_tool_needed != "":
				correct_tool = false
		destroy_progress += delta
		if destroy_progress >= destroy_time:
			Destroy(!(need_tool_to_drop and !correct_tool))
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
	
func Destroy(do_drop = true):
	if drop != null and do_drop:
		DropItem(drop)
	if inv != null:
		for i in inv.items:
			if i != null:
				DropItem(i)
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

func UpdateInChunkPos():
	chunkpos = get_tree().root.get_child(0).blockpos_to_inchunkpos(get_tree().root.get_child(0).pos_to_blockpos(global_position))
	return chunkpos
