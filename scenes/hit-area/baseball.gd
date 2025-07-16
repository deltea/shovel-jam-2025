class_name Baseball extends HitArea

@export var spin_speed_multiplier = 3.0

var pitch_speed = 100.0
var direction = Vector2.RIGHT

func _ready() -> void:
	await Clock.wait(45)
	queue_free()

func _process(dt: float) -> void:
	super._process(dt)

	sprite.rotation_degrees += pitch_speed * spin_speed_multiplier * dt
	position += direction * pitch_speed * dt

func _on_body_entered(body: Node2D) -> void:
	# if not body is Player:
	# 	queue_free()
	pass
