class_name item_drop
extends Sprite2D
@export var item:item_instance = null
@export var cantpickuptime = 0.5
@export var chunkparent:chunk

func _ready():
	pass
func _process(delta):
	UpdateItemDrop()
	if cantpickuptime > 0:
		cantpickuptime -= delta

func UpdateItemDrop():
	if item != null:
		if item.count < 1:
			Destroy()
		texture = item.item.image
	else:
		Destroy()

func Destroy():
	chunkparent.drops.erase(self)
	queue_free()


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") and cantpickuptime <= 0:
		body.inv.AddItem(item)
