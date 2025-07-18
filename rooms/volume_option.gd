extends SettingOption

func _enter_tree() -> void:
	option_name = "VOLUME"

func set_value(value: int):
	AudioManager.set_volume(value)
