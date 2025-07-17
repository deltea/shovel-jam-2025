class_name Level extends Room

@export var goal: Goal
@export var keys_parent: Node

@onready var keys_text: RichTextLabel = $Canvas/KeysText

var keys = []
var original_keys_length = 0

func _ready() -> void:
	keys = keys_parent.get_children()
	original_keys_length = keys.size()
	update_keys()

func collect_key(key: Key) -> void:
	keys.erase(key)
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
	# await Clock.wait(0.5)
	var tween = get_tree().create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(Engine, "time_scale", 0.0, 0.6)
