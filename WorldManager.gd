class_name WorldManager
extends Node2D

@export var objectlist:Array[PackedScene]
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
var treemap = FastNoiseLite.new()
var tempmap = FastNoiseLite.new()
var time = 0
var daytime = 0
var ingame_hour = 6

func _ready():
	if FileAccess.file_exists("user://save.data"):
		var file = FileAccess.open("user://save.data",FileAccess.READ)
		var data = file.get_var()
		if data != null:
			if data.has("player_pos"):
				player.position = data["player_pos"]
			if data.has("player_item_ids"):
				var e = 0
				for s in player.inv.items:
					var i = item_instance.new()
					if data["player_item_ids"].size() >= e + 1:
						if data["player_item_ids"][e] >= 0:
							i.item = itemman.itemlist[data["player_item_ids"][e]]
							i.count = data["player_item_counts"][e]
							player.inv.items[e] = i
					e += 1
			if data.has("cursor_id"):
				if data["cursor_id"] >= 0:
					player.cursor_item = item_instance.new()
					player.cursor_item.item = itemman.itemlist[data["cursor_id"]]
					player.cursor_item.count = data["cursor_count"]
		file.close()

func _save():
	var file = FileAccess.open("user://save.data",FileAccess.WRITE)
	var data = {}
	var item_ids = []
	var item_counts = []
	data["player_pos"] = player.position
	for s in player.inv.items:
		var i = -1
		var c = 0
		if s != null:
			i = s.item.id
			c = s.count
		item_ids.append(i)
		item_counts.append(c)
	data["player_item_ids"] = item_ids
	data["player_item_counts"] = item_counts
	var i = -1
	var ic = 0
	if player.cursor_item != null:
		i = player.cursor_item.item.id
		ic = player.cursor_item.count
	data["cursor_id"] = i
	data["cursor_count"] = ic
	file.store_var(data)
	file.close()
	for c in get_tree().get_nodes_in_group("Chunk"):
			UnloadChunk(c)

func _process(delta):
	time += delta
	daytime = fmod(time + 60*6, 60*24)
	ingame_hour = (daytime/60)

	if loadchunks:
		chunkinterval_progress += delta
		if chunkinterval_progress >= chunkinterval:
			chunkinterval_progress = 0
			ChunkloadCycle()

func ChunkloadCycle():
	if player.last_chunkpos != pos_to_chunkpos(player.position) or !startuploaddone:
		player.last_chunkpos = pos_to_chunkpos(player.position)
		startuploaddone = true
		for c in get_tree().get_nodes_in_group("Chunk"):
			if c.position.distance_to(player.position) > load_distance:
				UnloadChunk(c)
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
		if !FileAccess.file_exists("user://chunk(" + str(pos_to_chunkpos(c.position).x) + ", " + str(pos_to_chunkpos(c.position).y) + ").data"):
			for x in range(-8,8,1): # loop through every block position in the chunk
				for y in range(-8,8,1):
					var height = heightmap.get_noise_2d((c.position.x+(x*128))/200,(c.position.y+(y*128))/200)
					var treevalue = treemap.get_noise_2d((c.position.x+(x*128)),(c.position.y+(y*128)))
					var temp = tempmap.get_noise_2d((c.position.x+(x*128))/2000,(c.position.y+(y*128))/2000)
					var desert_temp_threshold = 0.3
					var snow_threshold = -0.3
					var block = grass # grass
					if temp > desert_temp_threshold:
						block = objectlist[6] # sand
					if temp < snow_threshold:
						block = objectlist[10]
					if height < 0: # water
						if temp >= snow_threshold:
							block = water
						else:
							block = objectlist[9]
					elif height > 0.35: # rockfloor
						if temp <= desert_temp_threshold:
							block = rockfloor
						else:
							block = objectlist[8]
					AddBlockToChunk(c,block,x,y)
					if height > 0.35 and height < 0.45: # rockhill
						if temp <= desert_temp_threshold:
							AddBlockToChunk(c,rockhill,x,y)
						else:
							AddBlockToChunk(c,objectlist[7],x,y)
					elif height > 0.3 and height < 0.35 and treevalue > (0.5 - height/3.75) and temp <= desert_temp_threshold: # fallen tree
						AddBlockToChunk(c,objectlist[5],x,y)
					elif height > 0.15 and height < 0.35 and treevalue > 0 and temp <= desert_temp_threshold: # tree
						AddBlockToChunk(c,objectlist[4],x,y)
		else:
			var file = FileAccess.open("user://chunk(" + str(pos_to_chunkpos(c.position).x) + ", " + str(pos_to_chunkpos(c.position).y) + ").data",FileAccess.READ)
			var data = file.get_var()
			if data != null:
				var i = 0
				for b in data["ids"]:
					var px = (data["poses"][i].x)
					var py = (data["poses"][i].y)
					AddBlockToChunk(c,objectlist[b],px,py)
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
			file.close()

func UnloadChunk(c):
	var file = FileAccess.open("user://chunk" + str(pos_to_chunkpos(c.position)) + ".data",FileAccess.WRITE)
	var data = {}
	var ids = []
	var poses = []
	var drop_ids = []
	var drop_poses = []
	var drop_counts = []
	for b in c.blocks:
		ids.append(b.id)
		poses.append(b.chunkpos)
	for d in c.drops:
		drop_ids.append(d.item.item.id)
		drop_counts.append(d.item.count)
		drop_poses.append(d.global_position)
	data["ids"] = ids
	data["poses"] = poses
	data["drop_ids"] = drop_ids
	data["drop_poses"] = drop_poses
	data["drop_counts"] = drop_counts
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

func GetChunkFromChunkPos(chunkpos):
	if loadedchunkpositions.has(chunkpos):
		for c in get_tree().get_nodes_in_group("Chunk"):
			if pos_to_chunkpos(c.position) == chunkpos:
				return c
	return null
