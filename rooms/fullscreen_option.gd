extends SettingOption

func _enter_tree() -> void:
	option_name = "FULLSCREEN"

func set_value(value: int):
	if value > 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
