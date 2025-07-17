class_name Goal extends HitArea

@export var disabled_color = Color.BLACK
@export var enabled_color = Color.WHITE

var enabled = false

func _ready() -> void:
	sprite.self_modulate = disabled_color

func enable():
	sprite.self_modulate = enabled_color
	enabled = true

func hit():
	if not enabled:
		return

	# super.hit()
	if RoomManager.current_room is Level:
		RoomManager.current_room.hit_goal()
