class_name slot
extends TextureRect
@export var amounttext:Label
@export var image:TextureRect
@export var id = 0
@export var inv:inventory
@export var cant_put_into = false

func _on_gui_input(event):
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
				if ii.item.id == item.item.id and ii.count != ii.item.maxcount and !cant_put_into:
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
				elif !cant_put_into:
					var e = ii.duplicate()
					var i = item.duplicate()
					player.cursor_item = e
					inv.items[id] = i
			elif !cant_put_into:
				inv.items[id] = item.duplicate()
				player.cursor_item = null
				return
		else:
			if inv.items[id] != null:
				player.cursor_item = inv.items[id].duplicate()
				inv.items[id] = null
	elif click_index == 2:
		if player.cursor_item != null:
			if inv.items[id] == null:
				inv.items[id] = player.cursor_item.duplicate()
				inv.items[id].count = 1
				player.cursor_item.count -= 1
				return
			if inv.items[id].item.id == item.item.id:
				if inv.items[id].count < inv.items[id].item.maxcount:
					inv.items[id].count += 1
					player.cursor_item.count -= 1
					return
