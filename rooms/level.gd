class_name Level extends Room

@export var goal: Goal
@export var keys_parent: Node

@onready var keys_text: RichTextLabel = $Canvas/KeysText
@onready var time_text: RichTextLabel = $Canvas/TimeText
@onready var results: Control = $Canvas/Results
@onready var results_text: RichTextLabel = $Canvas/Results/ResultsText
@onready var rank_text: RichTextLabel = $Canvas/Results/RankText
@onready var banner_text_1: RichTextLabel = $Canvas/Results/Banner/BannerText1
@onready var banner_text_2: RichTextLabel = $Canvas/Results/Banner/BannerText2

var keys = []
var original_keys_length = 0
var is_hit_goal = false
var end_time = 0.0
var strike_times = []
var results_shown = false
var banner_width = 0.0

func _ready() -> void:
	keys = keys_parent.get_children()
	original_keys_length = keys.size()
	update_keys()

func _process(dt: float) -> void:
	time_text.text = time_to_text(Clock.time, true)

	if results_shown and Input.is_action_just_pressed("c"):
		RoomManager.change_room("menu")

	# scroll banner text to the right forever with no gaps at a set speed
	banner_text_1.position.x -= 50 * dt
	banner_text_2.position.x -= 50 * dt

	if is_hit_goal:
		if banner_text_1.position.x + banner_width < 0:
				banner_text_1.position.x = banner_text_2.position.x + banner_width
		if banner_text_2.position.x + banner_width < 0:
				banner_text_2.position.x = banner_text_1.position.x + banner_width

func collect_key(key: Key) -> void:
	keys.erase(key)
	strike_times.append(Clock.time)
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

	end_time = Clock.time
	var rank = get_ranking(end_time)

	var text = "[wave freq=2 amp=6][color=#555]TIME[/color]   "
	text += time_to_text(end_time) + "\n\n\n"
	for i in range(len(strike_times)):
		text += "[color=#444]STRIKE  " + str(i + 1) + "[/color]   " + time_to_text(strike_times[i]) + "\n"
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

	var tween = get_tree().create_tween().set_parallel(true).set_ignore_time_scale(true)
	tween.tween_property(Engine, "time_scale", 0.0, 0.6)
	tween.tween_property(results, "position:y", 0.0, 1.0).set_delay(1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func():
		Engine.time_scale = 1.0
		rank_text.visible = true
		rank_text.text = "[shake level=10 rate=32]" + rank[0] + "[/shake]"
		rank_text.scale = Vector2.ONE * 3.5
	)
	tween.chain().tween_property(rank_text, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_property(results_text, "visible_ratio", 1.0, 1.0)
	tween.chain().tween_callback(func(): results_shown = true)

func time_to_text(time: float, spacing: bool = false) -> String:
	var minutes = int(time / 60)
	var seconds = int(fmod(time, 60))
	var milliseconds = int((time - int(time)) * 100)

	return ("%02d : %02d . %02d" if spacing else "%02d:%02d.%02d") % [minutes, seconds, milliseconds]

func get_ranking(time: float) -> Array[String]:
	if time < 40:
		return ["S", "SUPERB!"]
	elif time < 70:
		return ["A", "AMAZING!"]
	elif time < 110:
		return ["B", "NICE!"]
	elif time < 160:
		return ["C", "MEH"]
	else:
		return ["D", "YOU SUCK"]
