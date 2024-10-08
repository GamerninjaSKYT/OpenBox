class_name CraftingUI
extends ScrollContainer
@export var recipepackedscene:PackedScene
@export var ingredientslots:Array[slot]
@export var resultslot:slot
@export var recipes_ui:VBoxContainer
@export var search:LineEdit

func _ready():
	LoadRecipes()
func LoadRecipes(search_text = ""):
	for c in recipes_ui.get_children():
		c.queue_free()
		recipes_ui.custom_minimum_size.y = 0
	var m = get_tree().root.get_child(0).craftman
	for r in m.recipes:
		if search != null:
			if search_text != null and search_text != "":
				if r.result.item.name.findn(search_text) == -1:
					continue
		if r.ingredients.size() <= ingredientslots.size():
			var p = recipepackedscene.instantiate()
			recipes_ui.add_child(p)
			recipes_ui.custom_minimum_size.y += 270
			p.rec = r
			p.inv = ingredientslots[0].inv
			p.craftui = self
			p.resultname.text = r.result.item.name
			for im in p.ingredientimages:
				im.visible = false
			var n = 0
			for i in r.ingredients:
				p.ingredientimages[n].visible = true
				p.ingredientimages[n].texture = i.item.get_image()
				p.ingredientcounts[n].text = str(i.count)
				n += 1
			p.resultimage.texture = r.result.item.get_image()
			p.resultcount.text = str(r.result.count)
