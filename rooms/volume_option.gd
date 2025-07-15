extends SettingOption

func _enter_tree() -> void:
	option_name = "VOLUME"

func change_value(value: int):
	super.change_value(value)
	AudioManager.change_volume(value)
