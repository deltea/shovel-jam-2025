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
@export var boost_force = 500.0
@export var boost_time = 0.25

@export_category("Animation")
@export var run_tilt_angle = 20.0
@export var squash = 0.6
@export var stretch = 0.6

@onready var sprite: Sprite2D = $Sprite
@onready var dust_parent: Node2D = $DustParent
@onready var dust_particles: CPUParticles2D = $DustParent/DustParticles
@onready var ball_area: Area2D = $BallArea

var ball_scene = preload("res://scenes/ball/ball.tscn")

var jumped = false
var coyote_timer = 0.0
var buffer_timer = buffer_time
var boost_timer = boost_time
var can_move = true
var target_rotation_degrees = 0.0

func _enter_tree() -> void:
	RoomManager.current_room.player = self

func _process(dt: float) -> void:
	sprite.rotation_degrees = lerp(sprite.rotation_degrees, target_rotation_degrees, 50 * dt)

	if Input.is_action_just_pressed("fire") and not is_on_floor() and can_move:
		fire_ball()

func _physics_process(delta: float) -> void:
	coyote_timer += delta
	buffer_timer += delta
	boost_timer += delta

	var x_input := Input.get_axis("left", "right")

	if not is_on_floor():
		if boost_timer > boost_time:
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

	if boost_timer > boost_time:
		if can_move:
			target_rotation_degrees = x_input * run_tilt_angle
			if x_input:
				# x acceleration
				velocity.x = move_toward(velocity.x, x_input * max_speed, acceleration)
				dust_parent.scale.x = -x_input
				dust_particles.emitting = is_on_floor()
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

	if boost_timer <= boost_time:
		velocity.x = move_toward(velocity.x, 0.0, 25.0)
		velocity.y = move_toward(velocity.y, 0.0, 25.0)

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

	# ball checking
	var ball_check = ball_area.get_overlapping_bodies()
	if ball_check.size() > 0:
		for body in ball_check:
			if body is Ball:
				var ball = body as Ball
				if ball.can_boost:
					var direction = ball.velocity.normalized()
					velocity = direction * boost_force
					ball.queue_free()
					boost_timer = 0.0

func fire_ball() -> void:
	var ball = ball_scene.instantiate() as Ball
	var direction = (get_global_mouse_position() - position).normalized()
	ball.position = position + direction * 0.0
	ball.velocity = direction * ball.move_speed
	RoomManager.current_room.add_child(ball)
