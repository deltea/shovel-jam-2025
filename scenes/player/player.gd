class_name Player extends CharacterBody2D

@export_category("Movement")
@export var max_speed = 150.0
@export var jump_velocity = 300.0
@export var gravity = 1200.0
@export var fall_gravity = 1400.0
@export var wall_fall_velocity = 160.0
@export var acceleration = 40.0
@export var deceleration = 15.0
@export var coyote_time = 0.15
@export var buffer_time = 0.15
@export var push_force = 0.0
@export var parry_velocity = 400.0
@export var double_jump_velocity = 320.0
@export var parry_extra_y = 100.0
# @export var parrying_acceleration = 2000.0

@export_category("Animation")
@export var run_tilt_angle = 20.0
@export var double_jump_particles: PackedScene

@onready var sprite: Sprite2D = $Sprite
@onready var dust_parent: Node2D = $DustParent
@onready var dust_particles: CPUParticles2D = $DustParent/DustParticles
@onready var bat_flip: Node2D = $BatAnchor/BatFlip
@onready var bat_anchor: Node2D = $BatAnchor
@onready var bat_sprite: Sprite2D = $BatAnchor/BatFlip/Sprite
@onready var bat_collider: Area2D = $BatArea

var jumped = false
var coyote_timer = 0.0
var buffer_timer = buffer_time
var can_move = true
var target_rotation_degrees = 0.0
var direction = 1
var can_hit = true
var is_hitting = false

func _enter_tree() -> void:
	RoomManager.current_room.player = self

func _ready() -> void:
	# target_bat_rotation = bat_sprite.rotation
	pass

func _process(dt: float) -> void:
	dust_parent.scale.x = -direction
	sprite.rotation_degrees = lerp(sprite.rotation_degrees, target_rotation_degrees, 50 * dt)

	# bat positioning
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var bat_direction = rad_to_deg((input_dir * direction).angle())
	if input_dir.length() < 0.1:
		bat_direction = 0.0

	bat_anchor.position = bat_anchor.position.lerp(sprite.global_position, 60 * dt)
	bat_flip.scale.x = lerp(bat_flip.scale.x, float(-direction), 20 * dt)
	bat_anchor.rotation_degrees = lerp(bat_anchor.rotation_degrees, bat_direction, 50 * dt)

	bat_collider.rotation_degrees = bat_direction
	bat_collider.scale.x = direction

	if Input.is_action_just_pressed("x") and can_hit:
		swing_bat(-input_dir if input_dir.length() > 0 else Vector2(-direction, 0))

func _physics_process(dt: float) -> void:
	coyote_timer += dt
	buffer_timer += dt

	var x_input := Input.get_axis("left", "right")

	if not is_on_floor():
		if velocity.y > 0:
			if is_on_wall() and x_input:
				velocity.y = wall_fall_velocity
			else:
				velocity.y += fall_gravity * dt
		else:
			velocity.y += gravity * dt

	if can_move:
		target_rotation_degrees = x_input * run_tilt_angle
		if is_hitting:
			# if x_input:
			# 	velocity.x += parrying_acceleration * dt * x_input

			var y_input = Input.get_axis("up", "down")
			# velocity.y += parrying_acceleration * dt * y_input
		else:
			if x_input:
				# x acceleration
				velocity.x = move_toward(velocity.x, x_input * max_speed, acceleration)
				dust_particles.emitting = is_on_floor()
				direction = x_input
			else:
				# x deceleration
				velocity.x = move_toward(velocity.x, 0.0, deceleration)
				dust_particles.emitting = false

			# variable jump height
			if Input.is_action_just_released("c") and velocity.y < 0:
				velocity.y *= 0.5
	else:
		velocity.x = 0

	if Input.is_action_just_pressed("c") or buffer_timer < buffer_time and not jumped and can_move:
		if is_on_floor() or coyote_timer < coyote_time:
			velocity.y = -jump_velocity
			jumped = true

	if Input.is_action_just_pressed("c") and not is_on_floor():
		buffer_timer = 0.0

	if is_on_floor():
		can_hit = true

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
	$ParryTimer.start()

	var tween = get_tree().create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(bat_anchor, "scale:x", -1, 0.0)
	tween.tween_property(bat_sprite, "rotation", deg_to_rad(90), 0.0)

	tween.chain().tween_callback(func():
		bat_anchor.z_index = 5

		var collisions = bat_collider.get_overlapping_areas()
		var filtered_collisions = collisions.filter(func(area): return area is HitArea)
		if filtered_collisions.size() > 0:
			is_hitting = true
			velocity = dir * parry_velocity + Vector2(0, -parry_extra_y)
			filtered_collisions[0].hit()
			RoomManager.current_room.camera.impact_tilt(direction)
		else:
			is_hitting = true
			velocity = dir * double_jump_velocity
			can_hit = false

			var particles = double_jump_particles.instantiate() as CPUParticles2D
			particles.global_position = global_position
			particles.emitting = true
			particles.connect("finished", particles.queue_free)
			RoomManager.current_room.add_child(particles)
	)

	tween.chain().tween_property(bat_anchor, "scale:x", 1, 0.15).set_delay(0.1)
	tween.tween_property(bat_sprite, "rotation", deg_to_rad(20), 0.15)
	tween.chain().tween_callback(func():
		bat_anchor.z_index = -5
	)

func _on_parry_timer_timeout() -> void:
	is_hitting = false
