class_name Key extends Area2D

var original_position

func _ready() -> void:
	original_position = position

func _process(dt: float) -> void:
	position.y = sin(Clock.time * 2.0) * 5.0 + original_position.y
	rotation_degrees += 40.0 * dt

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		queue_free()
		if RoomManager.current_room is Level:
			RoomManager.current_room.collect_key(self)
