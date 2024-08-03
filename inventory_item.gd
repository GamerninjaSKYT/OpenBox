class_name inventory_item
extends Resource

@export var name:String = ""
@export var image:Texture2D
@export var id = 0 #each item has to have a unigue id
@export var maxcount = 100 #item stack size
@export var build_id = -1 #keep to -1 if not buildable
@export var build_sprite:Texture2D #keep null if not buildable
@export var build_offset = Vector2.ZERO
@export var build_col_size = Vector2(6.25,6.25)
@export var build_sprite_offset = Vector2.ZERO
