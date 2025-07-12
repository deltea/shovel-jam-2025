extends CanvasLayer

@export var default_palette: Texture2D

var palette: Texture2D

func set_color_palette(new_palette: Texture2D = null):
	if not default_palette:
		print("default palette not set")
		return

	palette = default_palette
	if new_palette:
		palette = new_palette

	print("color palette changed to " + palette.resource_path)

	$ColorRect.material.set_shader_parameter("palette_out", palette)
