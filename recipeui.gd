class_name recipeui
extends Control

@export var ingredientimages:Array[TextureRect]
@export var ingredientcounts:Array[Label]
@export var resultimage:TextureRect
@export var resultcount:Label
@export var rec:recipe
@export var inv:inventory
@export var craftui:CraftingUI
@export var resultname:Label

func _on_craft_button_down():
	if inv.items[craftui.resultslot.id] != null:
		if inv.items[craftui.resultslot.id].item.id != rec.result.item.id:
			return
		if inv.items[craftui.resultslot.id].count + rec.result.count > rec.result.item.maxcount:
			return
	var cancraft = true
	var n = 0
	for i in rec.ingredients:
		if inv.items[craftui.ingredientslots[n].id] == null:
			cancraft = false
		elif inv.items[craftui.ingredientslots[n].id].item.id != rec.ingredients[n].item.id:
			cancraft = false
		elif inv.items[craftui.ingredientslots[n].id].count < rec.ingredients[n].count:
			cancraft = false
		n += 1
	if cancraft:
		var nn = 0
		for ii in rec.ingredients:
			inv.items[craftui.ingredientslots[nn].id].count -= rec.ingredients[nn].count
			nn += 1
		if inv.items[craftui.resultslot.id] == null:
			inv.items[craftui.resultslot.id] = item_instance.new()
			inv.items[craftui.resultslot.id].count = 0
		inv.items[craftui.resultslot.id].item = rec.result.item
		inv.items[craftui.resultslot.id].count += rec.result.count


func _on_button_2_button_down():
	for i in range(rec.result.item.maxcount):
		_on_craft_button_down()
