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

func _process(delta):
	if mousehover:
		OnMouseHover()
	elif destroy_progress > 0 and destroyable:
		destroy_progress -= delta

func OnMouseHover():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and destroyable:
		destroy_progress += get_process_delta_time()
		if destroy_progress >= destroy_time:
			Destroy()

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
