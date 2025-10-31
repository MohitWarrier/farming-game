extends Node

signal day_changed(day : int)
signal player_tool_set(tool : PlayerTools.Tool, seed : CropData)
signal crop_harvested(crop : Crop)
signal seed_quantity_changed(crop : CropData, quantity : int)
signal money_changed(money : int)


var day : int = 0
var money : int = 0

var all_crop_data : Array[CropData] = [
		preload("res://Crops/tomato.tres"),
		preload("res://Crops/corn.tres"),
]

var owned_seeds : Dictionary[CropData, int]


# give initial money and seed to player
func _ready() -> void:
	
	get_tree().scene_changed.connect(_on_scene_changed)
	

# we do this because autloads are initialized when game starts.
# we start in menu scene and the signals emitted are not listened to
# by the main scene as it isnt active yet. 
func _on_scene_changed():
	if get_tree().current_scene.name != "Main":
		return
		
	# give time for the signal in give_money function
	# to connect to all the necessary nodes and signals
	give_money.call_deferred(10)
	for data in all_crop_data:
		give_seed.call_deferred(data, 2)
	set_next_day.call_deferred()
	


func set_next_day() -> void:
	day += 1
	day_changed.emit(day)
	
	
func harvest_crop(crop : Crop) -> void:
	give_money(crop.crop_data.sell_price)
	
	crop_harvested.emit(crop)
	crop.queue_free()
	
	
func try_buy_seed(crop_data : CropData) -> void:
	# cant buy if not enough money
	if money < crop_data.seed_price:
		return
		
	money -= crop_data.seed_price
	owned_seeds[crop_data] += 1
	
	money_changed.emit(money)
	seed_quantity_changed.emit(crop_data, owned_seeds[crop_data])
	

func consume_seed(crop_data : CropData) -> void:
	owned_seeds[crop_data] -= 1
	seed_quantity_changed.emit(crop_data, owned_seeds[crop_data])
	

func give_money(amount : int) -> void:
	money += amount
	money_changed.emit(money)
	
	
func give_seed(crop_data : CropData, amount : int):
	# check if crop exists in dict , if yes add amount
	# if no assign it 
	if owned_seeds.has(crop_data):
		owned_seeds[crop_data] += amount
	else:
		owned_seeds[crop_data] = amount
	
	seed_quantity_changed.emit(crop_data, owned_seeds[crop_data])
	
	
	
	
