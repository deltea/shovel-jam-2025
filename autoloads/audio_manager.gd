extends AudioStreamPlayer

var volume = 100

func set_volume(value: int):
	volume = clamp(value, 0, 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume / 100.0))

