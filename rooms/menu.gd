class_name MenuRoom extends Room

enum MenuState { START, SETTINGS, LEVEL_SELECT }

@onready var play_ball: Sprite2D = $Menus/TitleMenu/Options/PlayOption/PlayIcon
@onready var start_picker: Sprite2D = $Menus/TitleMenu/Picker
@onready var start_options: Node2D = $Menus/TitleMenu/Options
@onready var settings_options: Node2D = $Menus/SettingsMenu/Options
@onready var settings_picker: Sprite2D = $Menus/SettingsMenu/Picker
@onready var level_picker: Sprite2D = $Menus/LevelSelectMenu/Picker
@onready var planets: Node2D = $Menus/LevelSelectMenu/Planets

var state = MenuState.START
var select_index = 1
var target_picker_pos = Vector2.ZERO

func _ready() -> void:
	target_picker_pos = start_picker.position
	change_state(MenuState.START)

func _process(dt: float) -> void:
	# process for current state
	if state == MenuState.START:
		start_process(dt)
	elif state == MenuState.SETTINGS:
		settings_process(dt)
	elif state == MenuState.LEVEL_SELECT:
		level_select_process(dt)

func start_process(dt: float) -> void:
	# animations
	play_ball.rotation_degrees += 50 * dt
	var picker_offset = sin(Clock.time * 10) * 0.5
	start_picker.position = start_picker.position.lerp(target_picker_pos, 10 * dt) + Vector2(0, picker_offset)
	target_picker_pos = start_options.get_child(select_index).get_child(1).global_position + Vector2(0, -40)

	# moving the start_picker
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		var dir = Input.get_axis("left", "right")
		if dir > 0:
			select_index = min(2, select_index + 1)
		else:
			select_index = max(0, select_index - 1)

		camera.change_focus(Vector2(start_options.get_child(select_index).position.x, 0))

	# selecting option
	if Input.is_action_just_pressed("c"):
		if select_index == 0:
			change_state(MenuState.SETTINGS)
		elif select_index == 1:
			change_state(MenuState.LEVEL_SELECT)
		elif select_index == 2:
			get_tree().quit()

	# exit shortcut
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()

func settings_process(dt: float) -> void:
	# animations
	settings_picker.position.y = lerp(settings_picker.position.y, settings_options.get_child(select_index).global_position.y, 20 * dt)

	if Input.is_action_just_pressed("x"):
		change_state(MenuState.START)

	# move settings selection
	if Input.is_action_just_pressed("down") or Input.is_action_just_pressed("up"):
		var dir = Input.get_axis("up", "down")
		if dir > 0:
			select_index = min(settings_options.get_child_count() - 1, select_index + 1)
		else:
			select_index = max(0, select_index - 1)

		camera.change_focus(Vector2(0, settings_options.get_child(select_index).position.y))

	# change current selected setting
	if Input.is_action_just_pressed("c"):
		var current_option = settings_options.get_child(select_index)
		if current_option.has_method("select"):
			current_option.call("select")

	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		var dir = Input.get_axis("left", "right")
		var current_option = settings_options.get_child(select_index)
		if current_option.has_method("change_value"):
			current_option.call("change_value", dir)

func level_select_process(dt: float) -> void:
	# animations
	level_picker.global_position = lerp(level_picker.global_position, planets.get_child(select_index).global_position, 20 * dt)
	camera.change_focus(level_picker.position - Vector2(160, 120))

	if Input.is_action_just_pressed("x"):
		change_state(MenuState.START)

	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("up"):
		select_index = max(0, select_index - 1)
		planets.get_child(select_index).call("selected")
	elif Input.is_action_just_pressed("down") or Input.is_action_just_pressed("right"):
		select_index = min(planets.get_child_count() - 1, select_index + 1)
		planets.get_child(select_index).call("selected")

func change_state(new_state: MenuState) -> void:
	state = new_state
	select_index = 0  # reset selection index
	camera.change_focus(Vector2.ZERO)
	# camera.shake(0.1, 1)
	# Clock.hitstop(0.1)

	match state:
		MenuState.START:
			camera.position = $Menus/TitleMenu.position
			select_index = 1
		MenuState.SETTINGS:
			camera.position = $Menus/SettingsMenu.position
		MenuState.LEVEL_SELECT:
			camera.position = $Menus/LevelSelectMenu.position
			planets.get_child(select_index).call("selected")
		_:
			camera.position = $Menus/TitleMenu.position
