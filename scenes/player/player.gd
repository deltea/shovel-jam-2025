class_name Player extends CharacterBody2D

@export_category("Movement")
@export var max_speed = 150.0
@export var jump_velocity = 300.0
@export var gravity = 1200.0
@export var fall_gravity = 1600.0
@export var wall_fall_velocity = 80.0
@export var acceleration = 40.0
@export var deceleration = 15.0
@export var coyote_time = 0.15
@export var buffer_time = 0.15
@export var push_force = 0.0

@export_category("Animation")
@export var run_tilt_angle = 20.0
@export var squash = 0.6
@export var stretch = 0.6

@onready var sprite: Sprite2D = $Sprite
@onready var dust_parent: Node2D = $DustParent
@onready var dust_particles: CPUParticles2D = $DustParent/DustParticles
@onready var bat_anchor: Node2D = $Bat
@onready var bat_sprite: Sprite2D = $Bat/Sprite
@onready var bat_collider: Area2D = $BatArea

var jumped = false
var coyote_timer = 0.0
var buffer_timer = buffer_time
var can_move = true
var target_rotation_degrees = 0.0
var direction = 1

func _enter_tree() -> void:
	RoomManager.current_room.player = self

func _ready() -> void:
	# target_bat_rotation = bat_sprite.rotation
	pass

func _process(dt: float) -> void:
	dust_parent.scale.x = -direction
	sprite.rotation_degrees = lerp(sprite.rotation_degrees, target_rotation_degrees, 50 * dt)

	# bat positioning
	var bat_direction = (Input.get_vector("left", "right", "up", "down") if direction == 1 else Input.get_vector("right", "left", "down", "up")).angle()
	bat_anchor.position = bat_anchor.position.lerp(sprite.global_position, 60 * dt)

	bat_collider.rotation = bat_direction
	bat_collider.scale.x = direction

	if Input.is_action_just_pressed("x"):
		swing_bat(Vector2(-direction, Input.get_axis("down", "up")).normalized())

func _physics_process(delta: float) -> void:
	coyote_timer += delta
	buffer_timer += delta

	var x_input := Input.get_axis("left", "right")

	if not is_on_floor():
		if velocity.y > 0:
			if is_on_wall() and x_input:
				velocity.y = wall_fall_velocity
			else:
				velocity.y += fall_gravity * delta
		else:
			velocity.y += gravity * delta

		# variable jump height
		if Input.is_action_just_released("c") and velocity.y < 0:
			velocity.y *= 0.5

	if can_move:
		target_rotation_degrees = x_input * run_tilt_angle
		if x_input:
			# x acceleration
			velocity.x = move_toward(velocity.x, x_input * max_speed, acceleration)
			dust_particles.emitting = is_on_floor()
			direction = x_input
		else:
			# x deceleration
			velocity.x = move_toward(velocity.x, 0.0, deceleration)
			dust_particles.emitting = false
	else:
		velocity.x = 0

	if Input.is_action_just_pressed("c") or buffer_timer < buffer_time and not jumped and can_move:
		if is_on_floor() or coyote_timer < coyote_time:
			velocity.y = -jump_velocity
			jumped = true

	if Input.is_action_just_pressed("c") and not is_on_floor():
		buffer_timer = 0.0

	var was_on_floor = is_on_floor()
	move_and_slide()

	if not was_on_floor and is_on_floor():
		jumped = false
	elif was_on_floor and not is_on_floor() and not jumped:
		coyote_timer = 0.0

	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var collider = collision.get_collider()
		if collider is RigidBody2D and position.y > collider.position.y:
			(collider as RigidBody2D).apply_force(-collision.get_normal() * push_force)

func swing_bat(dir: Vector2):
	# bat_sprite.rotation = target_bat_rotation + PI

	# play tween
	var tween = get_tree().create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(bat_anchor, "scale:x", -1, 0.08)
	tween.tween_property(bat_sprite, "rotation", deg_to_rad(90), 0.08)

	tween.chain().tween_callback(func():
		Clock.hitstop(0.1)
		RoomManager.current_room.camera.shake(0.1, 1)
		bat_anchor.z_index = 5
	)

	tween.chain().tween_property(bat_anchor, "scale:x", 1, 0.15)
	tween.tween_property(bat_sprite, "rotation", deg_to_rad(20), 0.15)
	tween.chain().tween_callback(func():
		bat_anchor.z_index = -5
	)

	# var collisions = bat_collider.get_overlapping_bodies()
	# for body in collisions:
	# 	velocity = dir * 600
