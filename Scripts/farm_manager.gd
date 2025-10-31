class_name FarmManager
extends Node

enum TileType
{
	GRASS,
	TILLED,
	TILLED_WATERED,
}

var tile_info : Dictionary[Vector2i, TileInfo]
var crop_scene : PackedScene = preload("res://Scenes/crop.tscn")
var tile_atlas_coords : Dictionary[TileType, Vector2i] = {
		TileType.GRASS : Vector2i(0,0),
		TileType.TILLED : Vector2i(1,0),
		TileType.TILLED_WATERED : Vector2i(0,1),
}

@onready var farm_tile_map: TileMapLayer = $FarmTileMap
@onready var till_sound: AudioStreamPlayer = $TillSound
@onready var water_sound: AudioStreamPlayer = $WaterSound
@onready var plant_seed_sound: AudioStreamPlayer = $PlantSeedSound
@onready var harvest_sound: AudioStreamPlayer = $HarvestSound


func _ready() -> void:
	# connect to signals
	GameManager.day_changed.connect(_on_day_changed)
	GameManager.crop_harvested.connect(_on_crop_harvested)
	# loop through all tiles in our tile map
	# to populate our tile_info dict
	for tile in farm_tile_map.get_used_cells():
		# tile is a vector2i, we r passing the position as key
		tile_info[tile] = TileInfo.new()
		
	pass


func try_till_tile(player_pos : Vector2) -> void:
	# Get tile coordinates under player from their position
	# always use grid coordinates for tile operations
	var coords : Vector2i = farm_tile_map.local_to_map(player_pos)
	
	# dont till if there is a crop already on it
	if tile_info[coords].crop:
		return
		
	# dont till if tile is already tilled
	if tile_info[coords].tilled:
		return
	
	_set_tile_state(coords, TileType.TILLED)
	till_sound.play()
	

func try_water_tile(player_pos : Vector2) -> void:
	var coords : Vector2i = farm_tile_map.local_to_map(player_pos)
	
	# if tile is not tilled, can not water
	if not tile_info[coords].tilled:
		return

	_set_tile_state(coords, TileType.TILLED_WATERED)
	water_sound.play()
	# water crop tile
	if tile_info[coords].crop:
		tile_info[coords].crop.watered = true

func try_seed_tile(player_pos : Vector2, crop_data : CropData) -> void:
	var coords : Vector2i = farm_tile_map.local_to_map(player_pos)
	
	# can not seed if not tilled
	if not tile_info[coords].tilled:
		return
	
	# cant seed if crop already present 
	if tile_info[coords].crop:
		return
	
	# cant seed if we do not have the seed of current crop
	if GameManager.owned_seeds[crop_data] <= 0:
		return
	
	var crop : Crop = crop_scene.instantiate()
	add_child(crop)
	# Place crop at cell 'coords' on the tilemap
	crop.global_position = farm_tile_map.map_to_local(coords)
	crop.set_crop(crop_data, is_tile_watered(coords), coords)
	
	# assign crop to our tile_info dict
	tile_info[coords].crop = crop
	
	# remove 1 seed of this crop type
	GameManager.consume_seed(crop_data)
	plant_seed_sound.play()

func try_harvest_tile(player_pos : Vector2) -> void:
	var coords : Vector2i = farm_tile_map.local_to_map(player_pos)
	
	# can not harvest if no crop
	if not tile_info[coords].crop:
		return
	
	# crop must be fully grown
	if not tile_info[coords].crop.harvestable:
		return
	
	# sell crop
	GameManager.harvest_crop(tile_info[coords].crop)
	tile_info[coords].crop = null
	harvest_sound.play()
	
	
func is_tile_watered(pos : Vector2i) -> bool:
	var coords : Vector2i = farm_tile_map.local_to_map(pos)
	return tile_info[coords].watered


# set sprite of each tile depending on its state
func _set_tile_state(coords : Vector2i, tile_type : TileType) -> void:
	# Set the tile at 'coords' to the given type 
	# by looking up its atlas position, 0 is the layer index
	farm_tile_map.set_cell(coords, 0, tile_atlas_coords[tile_type])
	
	# set tile info according to tile state
	match tile_type:
		TileType.GRASS:
			tile_info[coords].tilled = false
			tile_info[coords].watered = false
		TileType.TILLED:
			tile_info[coords].tilled = true
			tile_info[coords].watered = false
		TileType.TILLED_WATERED:
			tile_info[coords].tilled = true
			tile_info[coords].watered = true


# on each new day, the watered tilled tiles become 
# normal tilled tiles and tilled tiles become grass
func _on_day_changed(_day : int) -> void:
	for tile_pos in farm_tile_map.get_used_cells():
		
		if tile_info[tile_pos].watered:
			_set_tile_state(tile_pos, TileType.TILLED)
		elif tile_info[tile_pos].tilled:
			if tile_info[tile_pos].crop == null:
				_set_tile_state(tile_pos, TileType.GRASS)


func _on_crop_harvested(crop: Crop) -> void:
	tile_info[crop.tilemap_coords].crop = null
	_set_tile_state(crop.tilemap_coords, TileType.TILLED)
	

class TileInfo:
	var tilled : bool
	var watered : bool
	var crop : Crop
