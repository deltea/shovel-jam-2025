extends Node

var save_data: Dictionary = {}
var save_file_path: String = "user://save.save"

func _enter_tree() -> void:
	load_save()
	print("save data loaded: " + str(save_data))

func save_game():
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("game saved")
	else:
		print("failed to open save file")

func load_save():
	if FileAccess.file_exists(save_file_path):
		var file = FileAccess.open(save_file_path, FileAccess.READ)
		if file:
			save_data = file.get_var()
			file.close()
			print("game loaded")
		else:
			print("failed to open save file")

func delete_save():
	if FileAccess.file_exists(save_file_path):
		DirAccess.remove_absolute(save_file_path)
		save_data.clear()
		print("save file deleted")
	else:
		print("no save file to delete")
