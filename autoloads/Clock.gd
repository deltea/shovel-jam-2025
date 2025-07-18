extends Node

var time = 0.0
var last_time = 0.0
var unscaled_dt = 0.0

func _process(delta: float) -> void:
	time += delta

	var unscaled_time = Time.get_ticks_msec() / 1000.0
	unscaled_dt = unscaled_time - last_time
	last_time = unscaled_time

func wait(duration: float):
	await get_tree().create_timer(duration, false, false, true).timeout

func hitstop(duration: float):
	Engine.time_scale = 0.0
	await wait(duration)
	Engine.time_scale = 1.0
