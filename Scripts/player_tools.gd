class_name PlayerTools
extends Node2D

enum Tool
{
	HOE,
	WATER_BUCKET,
	SCYTHE,
	SEED,
}

var current_tool : Tool
var current_seed : CropData

@onready var farm_manager: FarmManager = $"../../FarmManager"


func _ready() -> void:
	# connect signals
	GameManager.player_tool_set.connect(_on_player_tool_set)
	# emit signal for UI, use call_deferred to wait
	# for all connections to happen
	GameManager.player_tool_set.emit.call_deferred(Tool.HOE, null)

func _process(_delta: float) -> void:
	# handle interact input depending on selected tool and seed
	if Input.is_action_just_pressed("interact"):
		match current_tool:
			Tool.HOE:
				farm_manager.try_till_tile(global_position)
			Tool.WATER_BUCKET:
				farm_manager.try_water_tile(global_position)
			Tool.SCYTHE:
				farm_manager.try_harvest_tile(global_position)
			Tool.SEED:
				farm_manager.try_seed_tile(global_position, current_seed)
	

func _on_player_tool_set(tool : Tool, seed : CropData) -> void:
	current_tool = tool
	current_seed = seed
