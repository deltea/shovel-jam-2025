class_name CameraZone extends Area2D

const push_back_distance = 8.0

@onready var collider: CollisionShape2D = $CollisionShape

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		RoomManager.current_room.camera.limit_bottom = collider.global_position.y + collider.shape.extents.y + 8
		RoomManager.current_room.camera.limit_top = collider.global_position.y - collider.shape.extents.y - 8
		RoomManager.current_room.camera.limit_left = collider.global_position.x - collider.shape.extents.x - 8
		RoomManager.current_room.camera.limit_right = collider.global_position.x + collider.shape.extents.x + 8

		body.global_position -= (body.global_position - collider.global_position).normalized() * push_back_distance
