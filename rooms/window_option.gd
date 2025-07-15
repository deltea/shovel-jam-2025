extends SettingOption

func _enter_tree() -> void:
	option_name = "WINDOW"

func change_value(value: int):
	super.change_value(value)

	# change window size
	var new_size = Vector2(320, 240) * (current_value + 1)
	get_window().size = new_size
