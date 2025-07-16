class_name MovingHitAnchor extends Path2D

@export var move_speed = 0.5
@export var ping_pong = true

@onready var path_follow: PathFollow2D = $PathFollow
@onready var dotted_line: Line2D = $DottedLine

func _ready() -> void:
	dotted_line.points = curve.get_baked_points()

func _process(delta: float) -> void:
	if ping_pong:
		path_follow.progress_ratio = pingpong(Clock.time * move_speed, 1.0)
	else:
		path_follow.progress_ratio += move_speed * delta
