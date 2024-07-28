class_name CraftingUI
extends ScrollContainer
@export var recipepackedscene:PackedScene
@export var ingredientslots:Array[slot]
@export var resultslot:slot
@export var recipes_ui:VBoxContainer

func _ready():
	LoadRecipes()
func LoadRecipes():
	var m = get_tree().root.get_child(0).craftman
	for r in m.recipes:
		if r.ingredients.size() <= ingredientslots.size():
			print(r.result.item.name)
			var p = recipepackedscene.instantiate()
			recipes_ui.add_child(p)
