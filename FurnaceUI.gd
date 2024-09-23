class_name FurnaceUI
extends Node

@export var inv:inventory
@export var input:slot
@export var fuel:slot
@export var result:slot
@export var fuelamount:Label
@export var neededamount:Label
var m:craftmanager = null

func _ready():
	m = get_tree().root.get_child(0).craftman
func _process(delta):
	if inv.ui.visible:
		if inv.items[fuel.id] != null:
			var f = inv.items[fuel.id].item.fuel * inv.items[fuel.id].count
			if f != 1:
				fuelamount.text = str(f) + " fuel points"
			else:
				fuelamount.text = "1 fuel point"
		else:
			fuelamount.text = "No fuel"
		if inv.items[input.id] != null:
			for r in m.recipes_furnace:
				if r.input.id == inv.items[input.id].item.id:
					var n = r.fuelneeded * inv.items[input.id].count
					if n != 1:
						neededamount.text = str(n) + " fuel points needed"
					else:
						neededamount.text = "1 fuel point needed"
		else:
			neededamount.text = "no material"

func _on_smelt_button_down():
	var can_craft = false
	if inv.items[input.id] != null:
		for r in m.recipes_furnace:
			if r.input.id == inv.items[input.id].item.id:
				if inv.items[result.id] != null:
					if inv.items[result.id].item.id == r.result.item.id:
						if inv.items[result.id].count + r.result.count <= inv.items[result.id].item.maxcount:
							can_craft = true
				else:
					can_craft = true
				if can_craft and inv.items[fuel.id] != null:
					if inv.items[fuel.id].item.fuel * inv.items[fuel.id].count >= r.fuelneeded:
						inv.items[input.id].count -= 1
						if inv.items[result.id] == null:
							inv.items[result.id] = item_instance.new()
							inv.items[result.id].item = r.result.item
							inv.items[result.id].count = r.result.count
						else:
							inv.items[result.id].count += r.result.count
						inv.items[fuel.id].count -= ceil(r.fuelneeded/inv.items[fuel.id].item.fuel)


func _on_smelt_all_button_down():
	if inv.items[input.id] != null:
		for i in range(inv.items[input.id].count):
			_on_smelt_button_down()
