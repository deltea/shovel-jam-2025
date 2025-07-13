class_name Ball extends CharacterBody2D

@export var flash_color: Color = Color(1, 1, 1, 1)
@export var move_speed = 200.0

@onready var sprite: Sprite2D = $Sprite
@onready var particles: CPUParticles2D = $Particles

var original_modulate: Color
var can_boost = false

func _ready() -> void:
	original_modulate = sprite.self_modulate

func _physics_process(dt: float) -> void:
	velocity = velocity.normalized() * move_speed
	var collision = move_and_collide(velocity * dt)
	if collision:
		velocity = -velocity
		if not can_boost: can_boost = true

func _on_flash_timer_timeout() -> void:
	if sprite.self_modulate == original_modulate:
		sprite.self_modulate = flash_color
		particles.self_modulate = flash_color
	else:
		sprite.self_modulate = original_modulate
		particles.self_modulate = original_modulate
