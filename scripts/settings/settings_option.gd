class_name SettingOption extends Node2D

@export var value_max = 8
@export var value_min = 0
@export var initial_value = 8
@export var bool_value = false

@onready var label: RichTextLabel = $Label

var current_value = 0
var option_name = "OPTION"

func _ready() -> void:
	current_value = initial_value
	label.text = value_to_label(current_value)

# value is 1 or -1
func change_value(value: int) -> void:
	current_value = fmod(current_value + 1, value_max) if bool_value else clamp(current_value + value, value_min, value_max)
	label.text = value_to_label(current_value)
	RoomManager.current_room.camera.shake(0.08, 1.5)

func select():
	current_value = fmod(current_value + 1, value_max)
	label.text = value_to_label(current_value)
	RoomManager.current_room.camera.shake(0.08, 1.5)

func value_to_label(value: int) -> String:
	if bool_value:
		return option_name + " " + ("yup" if value > 0 else "nah")
	else:
		var label_str = ""
		for i in range(value_max):
			if i < value:
				label_str += "0"
			else:
				label_str += "-"
		return option_name + " " + label_str
