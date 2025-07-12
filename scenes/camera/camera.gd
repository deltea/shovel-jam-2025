class_name Camera extends Camera2D

func _enter_tree() -> void:
	RoomManager.current_room.camera = self
