class_name WorldManager
extends Node2D

var savepath = "user://saves/"
var worldpath = "world"

@export var objectlist:Dictionary
@export var creaturelist:Dictionary
@export var itemman:item_manager
@export var craftman:craftmanager
@export var player:Player
@export var itemdrop:PackedScene
@export_category("Chunk Generation")
@export var load_distance:float
var startuploaddone = false
@export var chunkinterval:float = 1
var chunkinterval_progress:float = chunkinterval
var loadchunks:bool = true
var loadedchunkpositions:Array[Vector2]
@export var packedchunk:PackedScene
@export var chunkgroup:Node
@export_category("World Generation")
@export var grass:PackedScene
@export var water:PackedScene
@export var rockhill:PackedScene
@export var rockfloor:PackedScene
var heightmap = FastNoiseLite.new()
var decormap = FastNoiseLite.new()
var tempmap = FastNoiseLite.new()
@export_category("Time and Weather")
var time = 0
var daytime = 0
var ingame_hour = 6
var day_beginning_hour = 6
var night_beginning_hour = 18
var is_day = true
var day = 1
var seed_int = 0

func _ready():
	if FileAccess.file_exists("user://load.data"):
		var f = FileAccess.open("user://load.data",FileAccess.READ)
		var data = f.get_var()
		seed_int = data["seed"]
		worldpath = data["name"]
		f.close()
	DirAccess.make_dir_recursive_absolute(savepath + worldpath)
	get_tree().auto_accept_quit = false
	player.nightdark.visible = true
	if FileAccess.file_exists(savepath + worldpath + "/save.data"):
		var file = FileAccess.open(savepath + worldpath + "/save.data",FileAccess.READ)
		var data = file.get_var()
		if data != null:
			if data.has("seed"):
				seed_int = data["seed"]
			if data.has("day_beginning_hour"):
				day_beginning_hour = data["day_beginning_hour"]
			if data.has("time"):
				time = data["time"]
			if data.has("player_pos"):
				player.position = data["player_pos"]
			if data.has("player_item_ids"):
				var e = 0
				for s in player.inv.items:
					var i = item_instance.new()
					if data["player_item_ids"].size() >= e + 1:
						if data["player_item_ids"][e] != "":
							i.item = itemman.itemlist[data["player_item_ids"][e]]
							i.count = data["player_item_counts"][e]
							player.inv.items[e] = i
					e += 1
			if data.has("cursor_id"):
				if data["cursor_id"] != "":
					player.cursor_item = item_instance.new()
					player.cursor_item.item = itemman.itemlist[data["cursor_id"]]
					player.cursor_item.count = data["cursor_count"]
			if data.has("spawnpoint"):
				player.spawnpoint = data["spawnpoint"]
			if data.has("hp"):
				player.hp = data["hp"]
			if data.has("hunger"):
				player.hunger = data["hunger"]
		file.close()
	heightmap.seed = seed_int
	decormap.seed = seed_int
	tempmap.seed = seed_int

func _save():
	var file = FileAccess.open(savepath + worldpath + "/save.data",FileAccess.WRITE)
	var data = {}
	var item_ids = []
	var item_counts = []
	data["hp"] = player.hp
	data["hunger"] = player.hunger
	data["spawnpoint"] = player.spawnpoint
	data["day_beginning_hour"] = day_beginning_hour
	data["time"] = time
	data["player_pos"] = player.position
	data["seed"] = seed_int
	for s in player.inv.items:
		var i = ""
		var c = 0
		if s != null:
			i = s.item.id
			c = s.count
		item_ids.append(i)
		item_counts.append(c)
	data["player_item_ids"] = item_ids
	data["player_item_counts"] = item_counts
	var i = ""
	var ic = 0
	if player.cursor_item != null:
		i = player.cursor_item.item.id
		ic = player.cursor_item.count
	data["cursor_id"] = i
	data["cursor_count"] = ic
	file.store_var(data)
	file.close()
	for c in get_tree().get_nodes_in_group("Chunk"):
			UnloadChunk(c, false)

func _process(delta):
	time += delta
	daytime = fmod(time + 60*day_beginning_hour, 60*24)
	ingame_hour = (daytime/60)
	is_day = (ingame_hour >= 6 and ingame_hour < 18)
	day = floor((time + 60*day_beginning_hour)/(60*24))+1
	player.nightdark.modulate.a = (float(abs(ingame_hour-12))/12)-0.5
	if loadchunks:
		chunkinterval_progress += delta
		if chunkinterval_progress >= chunkinterval:
			ChunkloadCycle()

func ChunkloadCycle():
	chunkinterval_progress = 0
	if player.last_chunkpos != pos_to_chunkpos(player.position) or !startuploaddone:
		player.last_chunkpos = pos_to_chunkpos(player.position)
		startuploaddone = true
		for c in get_tree().get_nodes_in_group("Chunk"):
			if c.position.distance_to(player.position) > load_distance:
				UnloadChunk(c, true)
		for x in range(-2,3,1):
			for y in range(-2,3,1):
				LoadChunkRelativeToPlayer(x,y)

func LoadChunkRelativeToPlayer(x_offset,y_offset):
	LoadChunk(pos_to_chunkpos(player.position) + Vector2(x_offset,y_offset))

func LoadChunk(pos):
	if !loadedchunkpositions.has(pos): # is a chunk already on this position?
		# CREATE CHUNK
		var c = packedchunk.instantiate() # if no create a new chunk
		chunkgroup.add_child(c) # add the created chunk into the world
		c.position = chunkpos_to_pos(pos) # set the position of the chunk
		loadedchunkpositions.append(pos_to_chunkpos(c.position)) # add it into the list of loaded chunks
		# GENERATE NEW - WORLD GENERATION CODE
		if !FileAccess.file_exists(savepath + worldpath + "/chunk(" + str(pos_to_chunkpos(c.position).x) + ", " + str(pos_to_chunkpos(c.position).y) + ").data"):
			for x in range(-8,8,1): # loop through every block position in the chunk
				for y in range(-8,8,1):
					var height = heightmap.get_noise_2d((c.position.x+(x*128))/200,(c.position.y+(y*128))/200)
					var decorvalue = decormap.get_noise_2d((c.position.x+(x*128)),(c.position.y+(y*128)))
					var temp = tempmap.get_noise_2d((c.position.x+(x*128))/2000,(c.position.y+(y*128))/2000)
					var desert_temp_threshold = 0.3
					var snow_threshold = -0.3
					var tree_temp_threshold = 0.275
					var block = grass # grass
					if temp > desert_temp_threshold:
						block = objectlist["sand_ground"] # sand
					if temp < snow_threshold:
						block = objectlist["snow"]
					if height < -0.1: # water
						if temp >= snow_threshold:
							block = water
						else:
							block = objectlist["ice_floor"]
					elif height > 0.35: # rockfloor
						if temp <= desert_temp_threshold:
							block = rockfloor
							if height > 0.45 and decorvalue > 0.5:
								AddBlockToChunk(c,objectlist["coal"],x,y)
						else:
							block = objectlist["sand_floor"]
					AddBlockToChunk(c,block,x,y)
					if height > 0.35 and height < 0.45: # rockhill
						if temp <= desert_temp_threshold:
							if decorvalue > 0.5:
								if decorvalue > 0.65:
									AddBlockToChunk(c,objectlist["gold"],x,y)#Gold
								else:
									AddBlockToChunk(c,objectlist["iron"],x,y)#Iron
							else:
								AddBlockToChunk(c,rockhill,x,y)
						else:
							if decorvalue > 0.55:
								AddBlockToChunk(c, objectlist["gold_sand"],x,y)
							else:
								AddBlockToChunk(c,objectlist["sand"],x,y)
					elif temp <= tree_temp_threshold:
						if height > 0.3 and height < 0.35 and decorvalue > (0.5 - height/3.75) and temp <= desert_temp_threshold and temp >= snow_threshold: # fallen tree
							AddBlockToChunk(c,objectlist["tree_fallen"],x,y)
						elif height < 0.35 and decorvalue > 0 and temp <= desert_temp_threshold and temp >= snow_threshold: # tree
							if height > 0.15:
								AddBlockToChunk(c,objectlist["tree"],x,y)
							elif height > 0 and decorvalue > 0.4:
								var bb = AddBlockToChunk(c,objectlist["blueberry_bush"],x,y)
								bb.grow = randf()*bb.growtime
						elif height > 0.15 and height < 0.35 and decorvalue > -0.2 and temp <= desert_temp_threshold and temp < snow_threshold:
							AddBlockToChunk(c,objectlist["snowtree"],x,y)
		else:
			var file = FileAccess.open(savepath + worldpath + "/chunk(" + str(pos_to_chunkpos(c.position).x) + ", " + str(pos_to_chunkpos(c.position).y) + ").data",FileAccess.READ)
			var data = file.get_var()
			if data != null:
				var i = 0
				for b in data["ids"]:
					#Load block
					var px = (data["poses"][i].x)
					var py = (data["poses"][i].y)
					var p = AddBlockToChunk(c,objectlist[b],px,py)
					if data.has("rots"):
						p.rotation = data["rots"][i]
					if data.has("made_walkable"):
						if p.can_walkable:
							p.col.set_collision_layer_value(1,!data["made_walkable"][i])
							p.col.set_collision_layer_value(2,data["made_walkable"][i])
							p.made_walkable = data["made_walkable"][i]
					if data.has("opens"):
						if p.is_door:
							p.OpenCloseDoor(data["opens"][i])
					if data.has("respawns"):
						p.set_respawn = data["respawns"][i]
					if data.has("grows"):
						p.grow = data["grows"][i]
					#Load inventory
					if p.inv != null:
						var item_ids = data["invs_ids"][i]
						var item_counts = data["invs_counts"][i]
						var item_i = 0
						for ii in p.inv.items:
							if item_ids.size() > item_i:
								if item_ids[item_i] != "-1":
									var item = item_instance.new()
									item.item = itemman.itemlist[item_ids[item_i]]
									item.count = item_counts[item_i]
									p.inv.items[item_i] = item.duplicate()
							item_i += 1
					i += 1
				if data.has("drop_ids"):
					var e = 0
					for d in data["drop_ids"]:
						var drop = get_tree().root.get_child(0).itemdrop.instantiate()
						GetChunkFromChunkPos(pos_to_chunkpos(data["drop_poses"][e])).add_child(drop)
						drop.global_position = data["drop_poses"][e]
						drop.item = item_instance.new()
						drop.item.item = itemman.itemlist[d]
						drop.item.count = data["drop_counts"][e]
						drop.chunkparent = GetChunkFromChunkPos(pos_to_chunkpos(data["drop_poses"][e]))
						drop.chunkparent.drops.append(drop)
						drop.UpdateItemDrop()
						e += 1
				if data.has("c_ids"):
					var ci = 0
					for cc in data["c_ids"]:
						var creatur = AddCreatureToPos(creaturelist[cc],data["c_poses"][ci])
						if data.has("c_hps"):
							creatur.hp = data["c_hps"][ci]
						ci += 1
			file.close()

func UnloadChunk(c, unloaded_by_distance):
	var file = FileAccess.open(savepath + worldpath + "/chunk" + str(pos_to_chunkpos(c.position)) + ".data",FileAccess.WRITE)
	var data = {}
	var ids = []
	var poses = []
	var rots = []
	var invs_ids = []
	var invs_counts = []
	var drop_ids = []
	var drop_poses = []
	var drop_counts = []
	var made_walkable = []
	var opens = []
	var respawns = []
	var grows = []
	var c_ids = []
	var c_poses = []
	var c_hps = []
	for b in c.blocks:
		ids.append(b.id)
		poses.append(b.chunkpos)
		rots.append(b.rotation)
		made_walkable.append(b.col.get_collision_layer_value(1) == false)
		opens.append(b.open)
		respawns.append(b.set_respawn)
		grows.append(b.grow)
		var item_ids = []
		var item_counts = []
		if b.inv != null:
			for i in b.inv.items:
				if i == null:
					item_ids.append("-1")
					item_counts.append(0)
				else:
					item_ids.append(i.item.id)
					item_counts.append(i.count)
		invs_ids.append(item_ids)
		invs_counts.append(item_counts)
	for d in c.drops:
		drop_ids.append(d.item.item.id)
		drop_counts.append(d.item.count)
		drop_poses.append(d.global_position)
	for cr in c.creatures:
		if !(unloaded_by_distance and cr.despawns): #dont save creatures that despawn
			c_ids.append(cr.id)
			c_poses.append(cr.global_position)
			c_hps.append(cr.hp)
	data["ids"] = ids
	data["poses"] = poses
	data["rots"] = rots
	data["drop_ids"] = drop_ids
	data["drop_poses"] = drop_poses
	data["drop_counts"] = drop_counts
	data["invs_ids"] = invs_ids
	data["invs_counts"] = invs_counts
	data["made_walkable"] = made_walkable
	data["opens"] = opens
	data["respawns"] = respawns
	data["grows"] = grows
	data["c_ids"] = c_ids
	data["c_poses"] = c_poses
	data["c_hps"] = c_hps
	file.store_var(data)
	file.close()
	loadedchunkpositions.erase(pos_to_chunkpos(c.position)) # removes the chunk from the list of chunks
	c.queue_free() # deletes the chunk

func pos_to_blockpos(pos):
	return Vector2(round(pos.x/128),round(pos.y/128))
func blockpos_to_chunkpos(pos):
	return Vector2(round(pos.x/16),round(pos.y/16))
func pos_to_chunkpos(pos):
	return blockpos_to_chunkpos(pos_to_blockpos(pos))
func blockpos_to_pos(pos):
	return Vector2(pos.x*128,pos.y*128)
func chunkpos_to_blockpos(pos):
	return Vector2(pos.x*16,pos.y*16)
func chunkpos_to_pos(pos):
	return blockpos_to_pos(chunkpos_to_blockpos(pos))
func position_snapped(pos:Vector2):
	return (pos/128).floor()*128
func blockpos_to_inchunkpos(pos):
	return -((chunkpos_to_pos(blockpos_to_chunkpos(pos))-pos*128)/128)

func AddBlockToChunk(chunk,block,x,y): # adds a block into a specific position inside a chunk
	var b = block.instantiate()
	chunk.add_child(b)
	b.position += Vector2(x,y)*128
	chunk.blocks.append(b)
	b.chunkparent = chunk
	b.chunkpos = Vector2(x,y)
	return b

func AddCreatureToPos(creature,pos):
	var c = creature.instantiate()
	var chunk = GetChunkFromChunkPos(pos_to_chunkpos(pos))
	chunk.add_child(c)
	c.global_position = pos
	chunk.creatures.append(c)
	c.chunkparent = chunk
	c.lastchunk = pos_to_chunkpos(pos)
	return c

func GetChunkFromChunkPos(chunkpos):
	if loadedchunkpositions.has(chunkpos):
		for c in get_tree().get_nodes_in_group("Chunk"):
			if pos_to_chunkpos(c.position) == chunkpos:
				return c
	return null

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save()
		get_tree().quit()

func GetBlocksInRadiusOnPos(radius, pos):
	var v_shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(v_shape_rid, radius)
	
	var v_query = PhysicsShapeQueryParameters2D.new()
	v_query.collide_with_areas = false
	v_query.collide_with_bodies = true
	v_query.shape_rid = v_shape_rid
	
	var v_transform = Transform2D()
	v_transform.origin = pos
	v_query.transform = v_transform
	
	var v_result = get_world_2d().direct_space_state.intersect_shape(v_query, 1000)
	var blocks = []
	for v in v_result:
		if v["collider"] is block:
			blocks.append(v["collider"])
	return blocks
	PhysicsServer2D.free_rid(v_shape_rid)
func GetCreaturesInRadiusOnPos(radius, pos):
	var v_shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(v_shape_rid, radius)
	
	var v_query = PhysicsShapeQueryParameters2D.new()
	v_query.collide_with_areas = false
	v_query.collide_with_bodies = true
	v_query.shape_rid = v_shape_rid
	
	var v_transform = Transform2D()
	v_transform.origin = pos
	v_query.transform = v_transform
	
	var v_result = get_world_2d().direct_space_state.intersect_shape(v_query, 1000)
	var creatures = []
	for v in v_result:
		if v["collider"] is creature:
			creatures.append(v["collider"])
	return creatures
	PhysicsServer2D.free_rid(v_shape_rid)
