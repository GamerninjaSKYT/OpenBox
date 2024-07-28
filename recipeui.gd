class_name recipeui
extends Control

@export var ingredientimages:Array[TextureRect]
@export var ingredientcounts:Array[Label]
@export var resultimage:TextureRect
@export var resultcount:Label
@export var rec:recipe
@export var inv:inventory
@export var craftui:CraftingUI

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
		n += 1
	print(cancraft)
