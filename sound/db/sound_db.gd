extends Node
class_name SoundDB

var db: Dictionary = {}


func _ready() -> void:
	var sound_folder_path = "res://assets/audio/used/"
	load_sounds_from_folder(sound_folder_path)
	print(db.keys())


func final_folder(folder_path: String) -> bool:
	var dir = DirAccess.open(folder_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name == '.' or file_name == '..' or file_name.ends_with('.import'):
				file_name = dir.get_next()
				continue
			if dir.current_is_dir():
				return false
			elif not file_name.ends_with(".wav"):
				return false
			file_name = dir.get_next()

	return true


func load_sounds_from_folder(folder_path: String, current_directory = db) -> void:
	var dir = DirAccess.open(folder_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if file_name == '.' or file_name == '..' or file_name.ends_with('.import'):
				file_name = dir.get_next()
				continue
			if dir.current_is_dir():
				var sub_folder_name = file_name
				var sub_folder_path = folder_path + sub_folder_name + "/"

				if !final_folder(sub_folder_path):
					print(str(sub_folder_name) + " is not a final folder!")
					if not current_directory.has(sub_folder_name):
						current_directory[sub_folder_name] = {}
					load_sounds_from_folder(sub_folder_path, current_directory[sub_folder_name])
				else:
					if not current_directory.has(sub_folder_name):
						current_directory[sub_folder_name] = []
					load_sounds_from_folder(sub_folder_path, current_directory[sub_folder_name])
			elif file_name.ends_with(".wav"):
				var sound_path = folder_path + file_name

				current_directory.append(load(sound_path))
			file_name = dir.get_next()


func clean_db(database) -> void:
	if database is Dictionary:
		for key in database.keys():
			clean_db(database[key])
	elif database is Array:
		for item in database:
			if item is not AudioStream:
				print(item)
