class_name CraftingUI
extends ScrollContainer
@export var recipepackedscene:PackedScene
@export var ingredientslots:Array[slot]
@export var resultslot:slot
@export var recipes_ui:VBoxContainer

func _ready():
	LoadRecipes()
func LoadRecipes():
	for c in recipes_ui.get_children():
		c.queue_free()
	var m = get_tree().root.get_child(0).craftman
	for r in m.recipes:
		if r.ingredients.size() <= ingredientslots.size():
			var p = recipepackedscene.instantiate()
			recipes_ui.add_child(p)
			for im in p.ingredientimages:
				im.visible = false
			var n = 0
			for i in r.ingredients:
				p.ingredientimages[n].visible = true
				p.ingredientimages[n].texture = i.item.image
				p.ingredientcounts[n].text = str(i.count)
				n += 1
			p.resultimage = r.result.item.image
			p.resultcount.text = str(r.result.count)
