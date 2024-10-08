class_name slot
extends TextureRect
@export var amounttext:Label
@export var image:TextureRect
@export var id = 0
@export var inv:inventory
@export var cant_put_into = false #Mouse input cant put an item here
@export var which_can_hold:Array[String]
var mouse_over = false
@export var preview:TextureRect
@export var preview_name:Label
@export var preview_desc:Label
@export var preview_dmg:Label
@export var preview_food:Label
@export var not_additem_target = false #Things like picking up an item wont affect this slot

func _process(delta):
	preview.visible = mouse_over and inv.items[id] != null
	if preview.visible:
		preview_name.text = inv.items[id].item.name
		preview_desc.text = inv.items[id].item.description
		preview_dmg.visible = (inv.items[id].item.damage > 0)
		preview_dmg.text = "Damage : " + str(inv.items[id].item.damage)
		preview_food.visible = (inv.items[id].item.food > 0)
		preview_food.text = "Food : " + str(inv.items[id].item.food/10)
	if mouse_over:
		inv.mouse_on_slot = true
		if Input.is_action_just_pressed("ML"):
			Click(1)
		if Input.is_action_just_pressed("MR"):
			Click(2)
func Click(click_index):
	var player = get_tree().root.get_child(0).player
	var item = player.cursor_item
	if click_index == 1:
		if item != null:
			var countlefttoadd = item.count
			var ii = inv.items[id]
			if ii != null:
				if ii.can_merge(item) and ii.count != ii.item.maxcount and !cant_put_into:
					inv.items[id].count += item.count
					countlefttoadd = 0
					player.cursor_item.count = 0
					if inv.items[id].count > inv.items[id].item.maxcount:
						countlefttoadd = inv.items[id].count - inv.items[id].item.maxcount
						inv.items[id].count = inv.items[id].item.maxcount
						player.cursor_item.count = countlefttoadd
					if countlefttoadd < 1:
						player.cursor_item = null
						return
				elif !cant_put_into and (which_can_hold.size() == 0 or which_can_hold.has(player.cursor_item.item.id)):
					var e = ii.duplicate()
					var i = item.duplicate()
					player.cursor_item = e
					inv.items[id] = i
			elif !cant_put_into and (which_can_hold.size() == 0 or which_can_hold.has(player.cursor_item.item.id)):
				inv.items[id] = item.duplicate()
				player.cursor_item = null
				return
		else:
			if inv.items[id] != null:
				player.cursor_item = inv.items[id].duplicate()
				inv.items[id] = null
	elif click_index == 2:
		if player.cursor_item != null and !cant_put_into:
			if inv.items[id] == null and (which_can_hold.size() == 0 or which_can_hold.has(player.cursor_item.item.id)):
				inv.items[id] = player.cursor_item.duplicate()
				inv.items[id].count = 1
				player.cursor_item.count -= 1
				return
			if item != null and inv.items[id] != null:
				if inv.items[id].can_merge(item):
					if inv.items[id].count < inv.items[id].item.maxcount:
						inv.items[id].count += 1
						player.cursor_item.count -= 1
						return


func _on_mouse_entered():
	mouse_over = true
func _on_mouse_exited():
	mouse_over = false
