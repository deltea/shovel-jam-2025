extends CanvasLayer

@onready var player: AnimationPlayer = $AnimationPlayer

var current_room: Room

func _ready() -> void:
	player.play("transition")
	set_color_palette()

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
	set_color_palette()
	player.play("transition")

func change_room_from_scene(scene: PackedScene):
	player.play_backwards("transition")
	await Clock.wait(0.5)

	get_tree().change_scene_to_packed(scene)

	await Clock.wait(0.5)

	set_color_palette()
	player.play("transition")

func reload_level():
	if current_room is Level:
		change_room(current_room.level_resource.name)

func set_color_palette():
	if current_room is Level:
		PaletteFilter.set_color_palette(current_room.level_resource.palette)
	else:
		PaletteFilter.set_color_palette(current_room.palette)
