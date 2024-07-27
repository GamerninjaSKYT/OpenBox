class_name inventory
extends Node

@export var slots:Array[slot]
@export var items:Array[item_instance]
@export var hotbarsize = 0
@export var selected_hotbar_slot = 0
@export var slotsprite:Texture2D
@export var selectedsprite:Texture2D
@export var mouse_on_slot = false
@export var ui:TextureRect

func _ready():
	items.resize(slots.size())

func _process(delta):
	if mouse_on_slot:
		mouse_on_slot = false
	if hotbarsize > 0:
		for s in slots:
			if slots.find(s) == selected_hotbar_slot:
				s.texture = selectedsprite
			else:
				s.texture = slotsprite
		if !ui.visible:
			if Input.is_action_just_released("MWU"):
				selected_hotbar_slot += 1
			elif Input.is_action_just_released("MWD"):
				selected_hotbar_slot -= 1
		if selected_hotbar_slot < 0:
			selected_hotbar_slot = hotbarsize - 1
		elif selected_hotbar_slot > hotbarsize - 1:
			selected_hotbar_slot = 0
		if Input.is_action_just_pressed("1"):
			selected_hotbar_slot = 0
		if Input.is_action_just_pressed("2"):
			selected_hotbar_slot = 1
		if Input.is_action_just_pressed("3"):
			selected_hotbar_slot = 2
		if Input.is_action_just_pressed("4"):
			selected_hotbar_slot = 3
		if Input.is_action_just_pressed("5"):
			selected_hotbar_slot = 4
		if Input.is_action_just_pressed("6"):
			selected_hotbar_slot = 5
		if Input.is_action_just_pressed("7"):
			selected_hotbar_slot = 6
		if Input.is_action_just_pressed("8"):
			selected_hotbar_slot = 7
		if Input.is_action_just_pressed("9"):
			selected_hotbar_slot = 8
		if Input.is_action_just_pressed("0"):
			selected_hotbar_slot = 9

func Updateslots():
	for s in slots:
		if items[slots.find(s)] != null:
			s.amounttext.visible = true
			s.amounttext.text = str(items[slots.find(s)].count)
			s.image.visible = true
			s.image.texture = items[slots.find(s)].item.image
			if items[slots.find(s)].count < 1:
				items[slots.find(s)] = null
		else:
			s.amounttext.visible = false
			s.image.visible = false

func is_hotbar(slot):
	return slots.find(slot) < hotbarsize

func AddItem(item:item_instance):
	var i = 0
	var countlefttoadd = item.count
	for s in slots:
		var ii = items[i]
		if ii != null:
			if ii.item.id == item.item.id and ii.count != ii.item.maxcount:
				items[i].count += item.count
				countlefttoadd = 0
				item.count = 0
				if items[i].count > items[i].item.maxcount:
					countlefttoadd = items[i].count - items[i].item.maxcount
					items[i].count = items[i].item.maxcount
					item.count = countlefttoadd
				if countlefttoadd < 1:
					item = null
					return
		else:
			items[i] = item.duplicate()
			item.count = 0
			return
		i += 1
