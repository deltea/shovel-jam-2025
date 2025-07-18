extends CanvasLayer

@onready var player: AnimationPlayer = $AnimationPlayer

var current_room: Room

func _ready() -> void:
	player.play("transition")
	PaletteFilter.set_color_palette(current_room.palette)

# func _process(_dt: float) -> void:
# 	player.advance(Clock.unscaled_dt)

func change_room(room: String):
	player.play_backwards("transition")
	await Clock.wait(0.5)

	var path = "res://rooms/" + room + ".tscn"
	if !ResourceLoader.exists(path):
		printerr("room not found: " + path)
		return

	var scene = load(path)
	get_tree().change_scene_to_packed(scene)

	await Clock.wait(0.5)
	PaletteFilter.set_color_palette(current_room.palette)
	player.play("transition")

func change_room_from_scene(scene: PackedScene):
	player.play_backwards("transition")
	await Clock.wait(0.5)

	get_tree().change_scene_to_packed(scene)

	await Clock.wait(0.5)
	PaletteFilter.set_color_palette(current_room.palette)
	player.play("transition")

func next_level():
	var level_num = get_tree().current_scene.name.erase(0, 5).to_int()
	change_room("levels/level_" + str(level_num + 1))
