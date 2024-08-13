class_name inventory_item
extends Resource

@export_category("General")
@export var name:String = ""
@export var description:String = ""
@export var image:Texture2D
@export var id:String = "" #each item has to have a unigue id
@export var maxcount = 100 #item stack size
@export_category("Build")
@export var build_id:String = "" #keep "" if not buildable
@export var build_sprite:Texture2D #keep null if not buildable
@export var build_offset = Vector2.ZERO
@export var build_col_size = Vector2(6.25,6.25)
@export var build_sprite_offset = Vector2.ZERO
@export var can_place_on_ids:Array[String]
@export var placement_ignores_player = false
@export var can_rotate = true
@export_category("Mining tool")
@export var mining_tool_type:String = ""
@export var mining_multiplier:float = 1
@export_category("Fuel")
@export var fuel:float = 0

func get_image():
	return image
func get_build_sprite():
	return build_sprite
