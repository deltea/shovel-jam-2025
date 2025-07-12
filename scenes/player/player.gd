class_name Player extends CharacterBody2D

func _enter_tree() -> void:
	RoomManager.current_room.player = self
