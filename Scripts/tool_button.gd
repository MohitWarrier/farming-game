class_name ToolButton
extends TextureButton

@export var tool : PlayerTools.Tool
@export var seed : CropData


@onready var quantity_text: Label = $QuantityText


func _ready() -> void:
	quantity_text.text = ""
	GameManager.seed_quantity_changed.connect(_on_seed_quantity_changed)

func _on_pressed() -> void:
	# emit signal
	GameManager.player_tool_set.emit(tool, seed)
	pass


func _on_mouse_entered() -> void:
	scale.x = 1.05
	scale.y = 1.05


func _on_mouse_exited() -> void:
	scale.x = 1
	scale.y = 1


func _on_seed_quantity_changed(crop_data : CropData, quantity : int) -> void:
	
	if seed != crop_data:
		return
	
	quantity_text.text = str(quantity)
	
	
	
	
