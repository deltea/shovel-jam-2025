class_name Key extends Area2D

var original_position

@onready var sprite: Sprite2D = $Sprite
@onready var explosion_particles: CPUParticles2D = $ExplosionParticles
@onready var collider: CollisionShape2D = $CollisionShape

func _ready() -> void:
	original_position = position
	explosion_particles.connect("finished", queue_free)

func _process(dt: float) -> void:
	position.y = sin(Clock.time * 2.0) * 5.0 + original_position.y
	rotation_degrees += 80.0 * dt

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		sprite.visible = false
		collider.set_deferred("disabled", true)
		explosion_particles.emitting = true

		# Clock.hitstop(0.1)
		RoomManager.current_room.camera.shake(0.1, 1.5)

		if RoomManager.current_room is Level:
			RoomManager.current_room.collect_key(self)
