class_name Level extends Room

@export var level_resource: LevelResource
@export var goal: Goal
@export var keys_parent: Node

@onready var keys_text: RichTextLabel = $Canvas/KeysText
@onready var time_text: RichTextLabel = $Canvas/TimeText
@onready var results: Control = $Canvas/Results
@onready var results_text: RichTextLabel = $Canvas/Results/ResultsText
@onready var rank_text: RichTextLabel = $Canvas/Results/RankText
@onready var banner_text_1: RichTextLabel = $Canvas/Results/Banner/BannerText1
@onready var banner_text_2: RichTextLabel = $Canvas/Results/Banner/BannerText2
@onready var indicators: Control = $Canvas/Results/Indicators
@onready var highscore_text: RichTextLabel = $Canvas/Results/HighScoreText

var keys = []
var original_keys_length = 0
var is_hit_goal = false
var end_time = 0.0
var strike_times = []
var results_shown = false
var banner_width = 0.0
var timer = 0.0

func _ready() -> void:
	keys = keys_parent.get_children()
	original_keys_length = keys.size()
	update_keys()
	results.visible = true

func _process(dt: float) -> void:
	time_text.text = Utils.time_to_text(timer, true)
	timer += dt

	if results_shown:
		if Input.is_action_just_pressed("c"):
			RoomManager.change_room("menu")
		if Input.is_action_just_pressed("x"):
			RoomManager.reload_level()

	indicators.rotation_degrees = sin(Clock.time * 2.0) * 3

	# scroll banner text to the right forever with no gaps at a set speed
	banner_text_1.position.x -= 50 * dt
	banner_text_2.position.x -= 50 * dt

	if is_hit_goal:
		if banner_text_1.position.x + banner_width < 0:
				banner_text_1.position.x = banner_text_2.position.x + banner_width
		if banner_text_2.position.x + banner_width < 0:
				banner_text_2.position.x = banner_text_1.position.x + banner_width
	else:
		if Input.is_action_just_pressed("restart"):
			RoomManager.reload_level()
		if Input.is_action_just_pressed("esc"):
			RoomManager.change_room("menu")

func collect_key(key: Key) -> void:
	keys.erase(key)
	strike_times.append(timer)
	print(str(keys.size()) + " keys left")
	update_keys()
	if keys.size() == 0:
		print("all keys collected")
		goal.enable()

func update_keys():
	var text = ""
	text += "X ".repeat(original_keys_length - keys.size())
	text += "- ".repeat(keys.size())
	text = text.substr(0, len(text) - 1)
	print("'" + text + "'")

	keys_text.text = "[wave]" + text

func hit_goal():
	if is_hit_goal:
		return
	is_hit_goal = true
	player.can_move = false

	# await Clock.wait(0.5)
	time_text.visible = false
	keys_text.visible = false

	end_time = timer
	var rank = Utils.get_ranking(end_time)

	var text = "[wave freq=2 amp=6][color=#555]TIME[/color]   "
	text += Utils.time_to_text(end_time) + "\n\n"
	for i in range(len(strike_times)):
		text += "[color=#444]STRIKE  " + str(i + 1) + "[/color]   " + Utils.time_to_text(strike_times[i]) + "\n"
	results_text.text = text

	results_text.visible_ratio = 0.0
	rank_text.visible = false
	rank_text.text = rank[0]

	var banner_text = (rank[1] + "  ").repeat(10)
	banner_text_1.text = banner_text
	banner_text_2.text = banner_text
	banner_width = banner_text_1.get_content_width()
	print("banner width: " + str(banner_width))
	banner_text_1.position.x = 0.0
	banner_text_2.position.x = banner_width

	indicators.visible = false
	highscore_text.visible = false

	# save time
	var beat_highscore = false
	if level_resource:
		if SaveManager.save_data.has("level_" + level_resource.name + "_time"):
			var previous_highscore = SaveManager.save_data["level_" + level_resource.name + "_time"]
			if end_time < previous_highscore:
				beat_highscore = true
				SaveManager.save_data["level_" + level_resource.name + "_time"] = end_time
				SaveManager.save_game()
		else:
			beat_highscore = true
			SaveManager.save_data["level_" + level_resource.name + "_time"] = end_time
			SaveManager.save_game()

	if beat_highscore:
		results_text.text += "\n\n"

	var tween = get_tree().create_tween().set_parallel(true).set_ignore_time_scale(true)
	tween.tween_property(Engine, "time_scale", 0.0, 0.6)
	tween.tween_property(results, "position:y", 0.0, 1.0).set_delay(1.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func():
		Engine.time_scale = 1.0
		rank_text.visible = true
		rank_text.text = "[shake level=10 rate=32]" + rank[0] + "[/shake]"
		rank_text.scale = Vector2.ONE * 3.5
	)
	tween.chain().tween_property(rank_text, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func():
		RoomManager.current_room.camera.shake(0.2, 1.5)
		AudioManager.play_sound(AudioManager.rank, 0.2)
	)
	tween.chain().tween_property(results_text, "visible_ratio", 1.5, 1.0)
	tween.chain().tween_callback(func():
		indicators.visible = true
		highscore_text.visible = beat_highscore
		results_shown = true
	)
