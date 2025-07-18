extends SettingOption

func _enter_tree() -> void:
	option_name = "WINDOW"

func set_value(value: int):
	var new_size = Vector2(320, 240) * (value + 1)
	get_window().size = new_size
