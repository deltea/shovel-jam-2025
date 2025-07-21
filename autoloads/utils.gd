extends Node

func get_ranking(time: float) -> Array[String]:
	if time < 50:
		return ["S", "SUPERB!"]
	elif time < 80:
		return ["A", "AMAZING!"]
	elif time < 120:
		return ["B", "NICE!"]
	elif time < 160:
		return ["C", "MEH"]
	else:
		return ["D", "TOO SLOW!"]

func time_to_text(time: float, spacing: bool = false) -> String:
	var minutes = int(time / 60)
	var seconds = int(fmod(time, 60))
	var milliseconds = int((time - int(time)) * 100)

	return ("%02d : %02d . %02d" if spacing else "%02d:%02d.%02d") % [minutes, seconds, milliseconds]
