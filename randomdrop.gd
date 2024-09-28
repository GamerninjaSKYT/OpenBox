class_name randomdrop
extends Resource

@export var item:item_instance
@export var mincount:int = 0
@export var maxcount:int = 0 #if 0, item.count determines the count
@export var percentagechance:float = 100

func randomize():
	if randf_range(0,100) <= percentagechance and percentagechance > 0:
		if maxcount != 0:
			item.count = randi_range(mincount,maxcount)
	else:
		item = null
