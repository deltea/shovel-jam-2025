class_name PlanetSelect extends Node2D

const spin_speed = 30

@export var level_resource: LevelResource

func _process(dt: float) -> void:
	rotation_degrees += spin_speed * dt

func selected():
	PaletteFilter.set_color_palette(level_resource.palette)

func get_level_highscore():
	if SaveManager.save_data.has("level_" + level_resource.name + "_time"):
		var time = SaveManager.save_data["level_" + level_resource.name + "_time"]
		return [time, Utils.get_ranking(time)]
	else:
		return []
