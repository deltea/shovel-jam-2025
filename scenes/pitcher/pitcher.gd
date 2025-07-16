class_name Pitcher extends Node2D

@export var ball_scene: PackedScene
@export var pitch_interval = 1.0
@export var pitch_speed = 100.0

@onready var sprite: Sprite2D = $Sprite
@onready var pitch_timer: Timer = $PitchTimer
@onready var shoot_particles: CPUParticles2D = $ShootParticles

func _ready() -> void:
	pitch_timer.wait_time = pitch_interval
	pitch_timer.start()

func _process(dt: float) -> void:
	sprite.scale = sprite.scale.lerp(Vector2.ONE, 10 * dt)

func _on_pitch_timer_timeout() -> void:
	sprite.scale = Vector2.ONE * 1.5
	shoot_particles.emitting = true

	var ball = ball_scene.instantiate() as Baseball
	ball.direction = Vector2.from_angle(rotation)
	ball.position = global_position + ball.direction * 8
	ball.pitch_speed = pitch_speed
	RoomManager.current_room.add_child(ball)
