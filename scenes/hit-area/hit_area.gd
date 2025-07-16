class_name HitArea extends Area2D

@onready var sprite = $Sprite
@onready var strike_sprite = $StrikeSprite
@onready var strike_timer = $StrikeTimer

func _process(dt: float) -> void:
	sprite.scale = sprite.scale.lerp(Vector2.ONE, 12 * dt)

func hit() -> void:
	strike_sprite.visible = true
	strike_timer.start()
	strike_sprite.rotation_degrees = randf_range(-180, 180)

	strike_sprite.scale = Vector2.ONE * 1.3
	sprite.scale = Vector2.ONE * 1.3

func _on_strike_timer_timeout() -> void:
	strike_sprite.visible = false
