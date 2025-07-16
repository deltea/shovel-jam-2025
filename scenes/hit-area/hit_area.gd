class_name HitArea extends Area2D

func hit() -> void:
	$StrikeSprite.visible = true
	$StrikeTimer.start()
	$StrikeSprite.rotation_degrees = randf_range(-180, 180)

func _on_strike_timer_timeout() -> void:
	$StrikeSprite.visible = false
