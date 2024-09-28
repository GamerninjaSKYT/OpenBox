class_name item_instance
extends Resource

@export var item:inventory_item
@export var count = 1

func can_merge(stack:item_instance):
	return item.id == stack.item.id
