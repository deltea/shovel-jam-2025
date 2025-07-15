extends AudioStreamPlayer

var volume = 100

func change_volume(dir: int):
	volume = clamp(volume + dir * 10, 0, 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume / 100.0))

