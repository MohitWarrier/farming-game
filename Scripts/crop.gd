class_name Crop
extends Node2D

var crop_data : CropData
var days_until_grown : int
var watered : bool
var harvestable : bool
var tilemap_coords : Vector2i

@onready var crop_sprite: Sprite2D = $CropSprite

func _ready() -> void:
	GameManager.day_changed.connect(_on_day_changed)
	

# setter function for our variables
func set_crop(data : CropData, already_watered : bool, tile_coords : Vector2i) -> void:
	crop_data = data
	watered = already_watered
	tilemap_coords = tile_coords
	harvestable = false
	
	days_until_grown = data.days_to_grow
	crop_sprite.texture = crop_data.growth_sprites[0]
	

func _on_day_changed(day : int) -> void:
	if not watered:
		return
	
	watered = false
	
	if days_until_grown != 1:	
		days_until_grown -= 1
	else:
		harvestable = true
	
	# our sprite counts might not be equal to days to grow.
	# so we get a percent (0-1) of growth 
	# and sample from our sprites according to the percent
	var sprite_count : int = len(crop_data.growth_sprites)
	var growth_percent : float = (crop_data.days_to_grow - \
			days_until_grown) / float(crop_data.days_to_grow)
	var index : int = floor(growth_percent * sprite_count)
	# clamp the index
	index = clamp(index, 0, sprite_count - 1)
	
	crop_sprite.texture = crop_data.growth_sprites[index]
	
