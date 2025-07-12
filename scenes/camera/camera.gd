class_name Camera extends Camera2D

@export var follow_speed = 3.0
@export var impact_rotation = 5.0
@export var shake_damping_speed = 1.0

var follow_enabled = true
var shake_duration = 0.0;
var shake_magnitude = 0.0;
var shake_offset = Vector2.ZERO

func _enter_tree() -> void:
	RoomManager.current_room.camera = self

func _process(delta: float) -> void:
	if RoomManager.current_room.player and follow_enabled:
		position = position.lerp(RoomManager.current_room.player.position, follow_speed * delta)

	# screen shake stuff
	if shake_duration > 0:
		shake_offset = Vector2.from_angle(randf_range(0, PI*2)) * shake_magnitude
		shake_duration -= delta * shake_damping_speed
	else:
		shake_duration = 0
		shake_offset = Vector2.ZERO

	offset = shake_offset

func shake(duration: float, magnitude: float):
	shake_duration = duration
	shake_magnitude = magnitude
