extends SettingOption

func _ready() -> void:
	pass

func change_value(value: int) -> void:
	pass

func select():
	SaveManager.delete_save()
	RoomManager.current_room.camera.shake(0.08, 1.5)
