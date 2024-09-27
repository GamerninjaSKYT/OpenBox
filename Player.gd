class_name Player
extends CharacterBody2D

var m:WorldManager
@export var col:CollisionShape2D
@export var base_speed = 400  # base speed in pixels/sec
@export var reach = 300
var last_chunkpos:Vector2
@export var image_front:Texture2D
@export var image_back:Texture2D
@export var image_side_left:Texture2D
@export var image_side_right:Texture2D
@export var sprite:Sprite2D
@export var buildzone:Area2D
@export var buildsprite:Sprite2D
@export var buildcan_color:Color
@export var buildcant_color:Color
@export var build_col:CollisionShape2D
var build_rot = 0
@export var inv:inventory
@export var cursor_item:item_instance
@export var inv_ui:TextureRect
@export var open_inv:inventory = null
@export var extended_inv:Control
@export var time_text:Label
@export var nightdark:TextureRect
@export var canbuild = true
@export var hp:float = 100
@export var maxhp:float = 100
@export var hpbar:ProgressBar
@export var hunger:float = 1000
@export var maxhunger:float = 1000
@export var hunger_heal_threshold:float = 750
@export var hungerbar:ProgressBar
@export var healinghunger:TextureRect
var spawnpoint:Vector2 = Vector2.ZERO
@export var notif_ui:TextureRect
@export var notif_text:Label
var notif_time = 0
var damage_delay = 0
@export var delay_bar:ProgressBar
@export var spriteanim:AnimationPlayer

func _ready():
	inv_ui.visible = false

func _process(delta):
	m = get_tree().root.get_child(0)
	if damage_delay > 0:
		damage_delay -= delta
		delay_bar.visible = true
		delay_bar.value = damage_delay
	else:
		delay_bar.visible = false
	if notif_time > 0:
		notif_time -= delta
	notif_ui.visible = (notif_time > 0)
	hpbar.value = hp
	hpbar.max_value = maxhp
	healinghunger.visible = (hunger >= hunger_heal_threshold)
	if hunger >= hunger_heal_threshold and hp < maxhp:
		hp += delta
	if hp > maxhp:
		hp = maxhp
	if hp <= 0:
		Die()
	if hunger > maxhunger:
		hunger = maxhunger
	if hunger <= 0:
		hunger = 0
		Damage(delta*4)
	else:
		hunger -= delta
	hungerbar.value = hunger
	hungerbar.max_value = maxhunger
	if time_text != null:
		var minute = floor(fmod(m.daytime,60))
		var additional_zero = ""
		if minute < 10:
			additional_zero = "0"
		time_text.text = "Day " + str(m.day) + " " + str(floor(m.ingame_hour)) + ":" + additional_zero + str(minute)
	inv.Updateslots()
	if inv.items[inv.selected_hotbar_slot] != null:
		if Input.is_action_just_pressed("MR") and open_inv == null and !inv.mouse_on_slot:
			UseItem(inv.items[inv.selected_hotbar_slot])
		if Input.is_action_just_pressed("ML") and open_inv == null and !inv.mouse_on_slot:
			UseItem(inv.items[inv.selected_hotbar_slot], false)
		if inv.items[inv.selected_hotbar_slot].item.build_id != "":
			if inv.items[inv.selected_hotbar_slot].item.can_rotate:
				if Input.is_action_just_pressed("rotate") and open_inv == null:
					build_rot = fmod(build_rot + 1,4)
			else:
				build_rot = 0
			if (UpdateBuildZone(inv.items[inv.selected_hotbar_slot].item)):
				if Input.is_action_pressed("MR") and open_inv == null and !inv.mouse_on_slot and canbuild:
					canbuild = false
					Build()
		else:
			buildsprite.visible = false
	else:
		buildsprite.visible = false
	if cursor_item != null:
		Input.set_custom_mouse_cursor(cursor_item.item.image)
		if cursor_item.count < 1:
			cursor_item = null
	else:
		Input.set_custom_mouse_cursor(null)
	inv_ui.visible = (open_inv != null)
	extended_inv.visible = (open_inv == inv)
	if Input.is_action_just_pressed("inv"):
		if open_inv != null:
			CloseInv()
		else:
			open_inv = inv #opens the player inventory
	if Input.is_action_just_pressed("ui_cancel"):
		if open_inv != null:
			CloseInv()
		else:
			pass #esc menu
	if Input.is_action_just_pressed("save") and open_inv == null:
		m._save()
		get_tree().quit()
	if Input.is_action_just_pressed("drop"):
		if inv.items[inv.selected_hotbar_slot] != null and open_inv == null:
			if !Input.is_action_pressed("shift"):
				DropItem(inv.items[inv.selected_hotbar_slot])
			else:
				DropItem(inv.items[inv.selected_hotbar_slot], inv.items[inv.selected_hotbar_slot].count)
	if Input.is_action_just_pressed("get_every") and open_inv == null:
		GetEveryItemInGame()
	if Input.is_action_just_pressed("b") and open_inv == null:
		m.AddCreatureToPos(m.creaturelist["caveling"],global_position)

func _physics_process(delta):
	if !inv_ui.visible:
		move() # move the player based on input
	
func move():
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * get_speed()
	if Input.is_action_pressed("left"):
		sprite.texture = image_side_left
	elif Input.is_action_pressed("right"):
		sprite.texture = image_side_right
	elif Input.is_action_pressed("down"):
		sprite.texture = image_front
	elif Input.is_action_pressed("up"):
		sprite.texture = image_back
	move_and_slide()

func CloseInv():
	open_inv.ui.visible = false
	open_inv = null

func Damage(damage):
	hp -= damage
	spriteanim.play("hit")

func Die():
	for i in inv.items:
		if i != null:
			DropItem(i, i.count)
	global_position = spawnpoint
	hp = maxhp
	hunger = maxhunger/10
	get_tree().root.get_child(0).ChunkloadCycle()

func UpdateBuildZone(item):
	buildsprite.visible = true
	var offset = item.build_offset
	if build_rot == 1:
		offset = Vector2(-item.build_offset.y, item.build_offset.x)
	if build_rot == 2:
		offset = Vector2(-item.build_offset.x, -item.build_offset.y)
	if build_rot == 3:
		offset = Vector2(item.build_offset.y, -item.build_offset.x)
	buildzone.global_position = m.position_snapped(get_global_mouse_position() + Vector2(64,64)) + offset
	buildzone.rotation = deg_to_rad(build_rot*90)
	buildsprite.texture = item.get_build_sprite()
	buildsprite.position = item.build_sprite_offset
	build_col.scale = item.build_col_size
	var obstructions = m.GetAllInRadiusOnPos(50,buildzone.global_position,buildzone.collision_mask)
	if item.placement_ignores_player and obstructions.has(self):
		obstructions.erase(self)
	for o in obstructions.duplicate():
		if o is block:
			if o.made_walkable:
				obstructions.erase(o)
			elif o.can_place_on and o.id != item.build_id and !item.ignores_can_place_on:
				obstructions.erase(o)
			elif item.can_place_on_ids.has(o.id):
				obstructions.erase(o)
	if obstructions.size() == 0 and buildzone.global_position.distance_to(global_position) <= reach:
		buildsprite.modulate = buildcan_color
		return true
	else:
		buildsprite.modulate = buildcant_color
		return false

func Build():
	inv.items[inv.selected_hotbar_slot].count -= 1
	var offset = inv.items[inv.selected_hotbar_slot].item.build_offset
	if build_rot == 1:
		offset = Vector2(-inv.items[inv.selected_hotbar_slot].item.build_offset.y, inv.items[inv.selected_hotbar_slot].item.build_offset.x)
	if build_rot == 2:
		offset = Vector2(-inv.items[inv.selected_hotbar_slot].item.build_offset.x, -inv.items[inv.selected_hotbar_slot].item.build_offset.y)
	if build_rot == 3:
		offset = Vector2(inv.items[inv.selected_hotbar_slot].item.build_offset.y, -inv.items[inv.selected_hotbar_slot].item.build_offset.x)
	var pos = m.pos_to_blockpos(buildzone.global_position - offset)
	var c = m.GetChunkFromChunkPos(m.blockpos_to_chunkpos(pos))
	var b = m.AddBlockToChunk(c,m.objectlist[inv.items[inv.selected_hotbar_slot].item.build_id],0,0)
	b.built = true
	b.global_position = pos*128
	b.rotation = deg_to_rad(build_rot*90)
	b.UpdateInChunkPos()
	if b.makes_walkable:
		b.MakeWalkable()

func get_speed(): # apply speed modifiers here
	return base_speed

func DropItem(item, amount = 1):
	var d = get_tree().root.get_child(0).itemdrop.instantiate()
	get_tree().root.get_child(0).GetChunkFromChunkPos(get_tree().root.get_child(0).pos_to_chunkpos(position)).add_child(d)
	d.global_position = global_position
	d.item = item.duplicate()
	if amount > item.count:
		amount = item.count
	d.item.count = amount
	d.chunkparent = get_tree().root.get_child(0).GetChunkFromChunkPos(get_tree().root.get_child(0).pos_to_chunkpos(position))
	d.chunkparent.drops.append(d)
	d.UpdateItemDrop()
	item.count -= amount

func UseItem(item:item_instance, right_click = true):
	if !Input.is_action_pressed("shift"):
		if item.item.damage > 0 and damage_delay <= 0 and !right_click:
			damage_delay = item.item.reload
			delay_bar.max_value = item.item.reload
			var targets = get_tree().root.get_child(0).GetCreaturesInRadiusOnPos(reach,global_position)
			for t in targets:
				t.Damage(item.item.damage)
		if item.item.food > 0 and right_click:
			hunger += item.item.food
			item.count -= 1

func GetEveryItemInGame():
	var items = get_tree().root.get_child(0).itemman.itemlist
	for i in items.values():
		var ii = item_instance.new()
		ii.item = i
		ii.count = i.maxcount
		DropItem(ii, ii.count)

func Notif(text = "", time = 2.0):
	notif_text.text = text
	notif_time = time
