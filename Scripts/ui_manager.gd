extends CanvasLayer

var tool_buttons : Array[ToolButton]

@onready var day_text: Label = $DayText
@onready var money_text: Label = $MoneyText


func _ready() -> void:
	# add our buttons into out array
	for button in $ToolButtons.get_children():
		if button is ToolButton:
			tool_buttons.append(button)
	
	GameManager.player_tool_set.connect(_on_player_tool_set)
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.day_changed.connect(_on_day_changed)

# give a green hue to the chosen tool
func _on_player_tool_set(tool : PlayerTools.Tool, seed : CropData) -> void:
	for button in tool_buttons:
		if button.tool != tool or button.seed != seed:
			button.self_modulate = Color.WHITE
		else:
			button.self_modulate = Color.SEA_GREEN
	

func _on_money_changed(money : int) -> void:
	money_text.text = str(money) + "$"	
	

func _on_day_changed(day : int) -> void:
	day_text.text = "Day " + str(day)
	

func _on_next_day_button_pressed() -> void:
	GameManager.set_next_day()
