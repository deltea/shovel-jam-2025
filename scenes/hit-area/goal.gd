class_name Goal extends HitArea

@export var disabled_color = Color.BLACK
@export var enabled_color = Color.WHITE

var enabled = false

func _ready() -> void:
	sprite.self_modulate = disabled_color

func _process(dt: float) -> void:
	super._process(dt)

	rotation_degrees += (80 if enabled else 20) * dt

func enable():
	sprite.self_modulate = enabled_color
	enabled = true

func hit():
	# super.hit()
	sprite.scale = Vector2.ONE * 1.5

	if enabled and RoomManager.current_room is Level:
		strike_sprite.visible = true
		strike_timer.start()
		strike_sprite.rotation_degrees = randf_range(-180, 180)

		strike_sprite.scale = Vector2.ONE * 1.5

		RoomManager.current_room.hit_goal()
