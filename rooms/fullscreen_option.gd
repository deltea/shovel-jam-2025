extends SettingOption

func _enter_tree() -> void:
	option_name = "FULLSCREEN"

func change_value(value: int):
	super.change_value(value)
	toggle_fullscreen()

func select():
	super.select()
	toggle_fullscreen()

func toggle_fullscreen() -> bool:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		return false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return true
