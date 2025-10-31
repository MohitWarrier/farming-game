class_name BuySeedButton
extends BaseButton


@export var crop_data : CropData


@onready var price_text: Label = $PriceText
@onready var icon: TextureRect = $Icon


func _ready() -> void:
	pressed.connect(_on_pressed)
	
	# return if no crop set
	if not crop_data:
		return
	
	price_text.text = str(crop_data.seed_price) + "$"	
	var last_sprite_index = len(crop_data.growth_sprites) - 1
	icon.texture = crop_data.growth_sprites[last_sprite_index]

func _on_pressed() -> void:
	GameManager.try_buy_seed(crop_data)
