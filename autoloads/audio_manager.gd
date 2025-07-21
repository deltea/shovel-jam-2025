extends AudioStreamPlayer

var music = preload("res://assets/music/main.wav")

# var jump = preload("res://assets/sfx/jump.wav")
# var double_jump = preload("res://assets/sfx/double_jump.wav")
var hit = preload("res://assets/sfx/hit.wav")
var strike = preload("res://assets/sfx/strike.wav")
var rank = preload("res://assets/sfx/rank.wav")
var swing = preload("res://assets/sfx/swing.wav")

var volume = 100

func _ready() -> void:
	connect("finished", func(): stream_paused = false)
	play_music()

func play_music():
	stream = music
	play()

func play_sound(sound: AudioStream, randomness: float = 0):
	var player = AudioStreamPlayer.new()
	player.pitch_scale = randf_range(1 - randomness, 1 + randomness)
	player.stream = sound
	player.connect("finished", player.queue_free)
	add_child(player)
	player.play()

func set_volume(value: int):
	volume = clamp(value, 0, 100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume / 100.0))

