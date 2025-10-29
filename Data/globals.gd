extends Node

# favorites[name, path]
var favorites: Dictionary = {}
var save_path: String = "user://data"


func _ready() -> void:
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
	
	if not FileAccess.file_exists(save_path + "/favorites.json"):
		create_save_file()


func load_favorites() -> void:
	if FileAccess.file_exists(save_path + "/favorites.json"):
		var file = FileAccess.open(save_path + "/favorites.json", FileAccess.READ)
		var data: Dictionary = JSON.parse_string(file.get_as_text())
		if data:
			print(data)
			favorites = data
		else:
			favorites = {}
	else:
		favorites = {}


func save_favorites() -> void:
	var file = FileAccess.open(save_path + "/favorites.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(favorites))
	file.close()


func create_save_file() -> void:
	var file = FileAccess.open(save_path + "/favorites.json", FileAccess.WRITE)
	file.store_string("{}")
	file.close()


func add_favorite(f_name: String, f_path: String) -> void:
	favorites[f_name] = f_path
	print(favorites)


func remove_favorite(f_name: String) -> void:
	favorites.erase(f_name)
	print(favorites)
