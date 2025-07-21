class_name PlanetSelect extends Sprite2D

const spin_speed = 30

@export var level_resource: LevelResource
@export var locked_texture: Texture2D
@export var locked_palette: Texture2D

var locked = false

func select() -> void:
	PaletteFilter.set_color_palette(locked_palette if locked else level_resource.palette)

func _process(dt: float) -> void:
	rotation_degrees += spin_speed * dt

func get_level_highscore():
	if SaveManager.save_data.has("level_" + level_resource.name + "_time"):
		var time = SaveManager.save_data["level_" + level_resource.name + "_time"]
		return [time, Utils.get_ranking(time)]
	else:
		return []

func update_locked_texture():
	if locked:
		texture = locked_texture
