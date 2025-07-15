class_name Camera extends Camera2D

@export var base_offset = Vector2.ZERO
@export var follow: Node2D
@export var follow_speed = 6.0
@export var impact_rotation = 5.0
@export var shake_damping_speed = 1.0
@export var focus_modifier = 0.08
@export var impact_tilt_damping = 5.0
@export var impact_tilt_magnitude = 2.0

var shake_duration = 0.0;
var shake_magnitude = 0.0;
var shake_offset = Vector2.ZERO
var focus_offset = Vector2.ZERO
var focus = Vector2.ZERO

func _enter_tree() -> void:
	RoomManager.current_room.camera = self

func _process(delta: float) -> void:
	if follow:
		position = position.lerp(follow.position, follow_speed * delta)

	# screen shake stuff
	if shake_duration > 0:
		shake_offset = Vector2.from_angle(randf_range(0, PI*2)) * shake_magnitude
		shake_duration -= delta * shake_damping_speed
	else:
		shake_duration = 0
		shake_offset = Vector2.ZERO

	# offset towards focus
	focus_offset = lerp(focus_offset, focus * focus_modifier, follow_speed * delta)
	offset = base_offset + shake_offset + focus_offset

	rotation_degrees = lerp(rotation_degrees, 0.0, impact_tilt_damping * delta)

func impact_tilt(direction: int):
	rotation_degrees = direction * impact_tilt_magnitude

func shake(duration: float, magnitude: float):
	shake_duration = duration
	shake_magnitude = magnitude

func change_focus(pos: Vector2):
	focus = pos
