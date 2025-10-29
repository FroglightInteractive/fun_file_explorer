extends HFlowContainer

@onready var path_label: Label = $"../../HBoxContainer/VBoxContainer/PathPanel/VBoxContainer/PathLabel"
@onready var favorites_container: VBoxContainer = $"../../HBoxContainer/FavoritesPanel/MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer"

var current_path: String
var search_term: String = ""
var filter_term: String = ""


func _ready() -> void:
	set_current_path(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	load_files(current_path)
	
	Globals.load_favorites()
	for fav in Globals.favorites.keys():
		var filename = fav
		var filepath = Globals.favorites[fav]
		
		var favorite_panel = preload("res://Panels/FavoritePanel/favorite_panel.tscn").instantiate()
		favorites_container.add_child(favorite_panel)
		favorite_panel.set_filename(filename)
		
		favorite_panel.set_filepath(filepath)
		favorite_panel.open_pressed.connect(_on_favorite_panel_open_pressed.bind(favorite_panel))
		favorite_panel.delete_pressed.connect(_on_favorite_panel_delete_pressed.bind(favorite_panel))
		
		if DirAccess.dir_exists_absolute(filepath):
			favorite_panel.set_color(Color(0.914, 0.553, 0.192))


func set_current_path(new_path: String) -> void:
	new_path = new_path.replace("//", "/")
	current_path = new_path
	path_label.text = new_path
	path_label.tooltip_text = new_path


func load_files(path: String, search: String = "") -> void:
	for child in get_children():
		child.queue_free()
	
	var dir := DirAccess.open(path)
	if not dir:
		print("No directory found: ", path)
		return
	
	dir.list_dir_begin()
	var files: Array[String] = []
	var filename := dir.get_next()
	while filename != "":
		if filename != "." and filename != "..":
			files.append(filename)
		filename = dir.get_next()
	dir.list_dir_end()
	
	# sort alphabetically
	files.sort_custom(func(a, b): return a.to_lower() < b.to_lower())

	# separate folders and files
	var folders: Array[String] = []
	var regular_files: Array[String] = []
	for f in files:
		var abs_f = path.path_join(f)
		if DirAccess.dir_exists_absolute(abs_f):
			folders.append(f)
		else:
			regular_files.append(f)
	
	var sorted_files = folders + regular_files

	# apply fuzzy search
	if search != "":
		sorted_files = sorted_files.filter(func(f): return fuzzy_match(f, search))

	# apply file extension filters
	if filter_term != "":
		var filters: Array[String] = []
		for f in filter_term.split(",", false):
			var clean = f.strip_edges().to_lower()
			if clean.begins_with("."):
				clean = clean.substr(1)  # remove leading dot if user types ".png"
			if clean != "":
				filters.append(clean)
		
		sorted_files = sorted_files.filter(func(f):
			var abs_f = path.path_join(f)
			
			# always remove folders
			if DirAccess.dir_exists_absolute(abs_f):
				return false
			
			# get extension (may be empty string if file has no extension)
			var ext = f.get_extension().to_lower()
			if ext == "":
				return false  # files with no extension won't match
			
			# exact or fuzzy match for any listed filter
			for flt in filters:
				if ext == flt or fuzzy_match(ext, flt):
					return true
			
			return false
		)
	
	# create file panels
	for file in sorted_files:
		var file_button = preload("res://Panels/FilePanel/file_panel.tscn").instantiate()
		add_child(file_button)
		file_button.set_filename(file)
		file_button.favorite_pressed.connect(_on_file_favorite_pressed.bind(file))
		
		var abs_path = path.path_join(file)
		
		if DirAccess.dir_exists_absolute(abs_path):
			file_button.open_pressed.connect(_on_folder_opened.bind(file))
			file_button.set_color(Color(0.914, 0.553, 0.192))
		else:
			file_button.open_pressed.connect(_on_file_opened.bind(file))


func _on_file_opened(filename: String) -> void:
	var abs_path = current_path + "/" + filename
	OS.shell_open(abs_path)


func _on_folder_opened(foldername: String) -> void:
	var abs_path = current_path + "/" + foldername
	set_current_path(abs_path)
	load_files(current_path, search_term)


func _on_folder_up_pressed() -> void:
	var new_path = current_path.get_base_dir()
	set_current_path(new_path)
	load_files(current_path, search_term)


func _on_file_favorite_pressed(filename: String) -> void:
	var favorite_panel = preload("res://Panels/FavoritePanel/favorite_panel.tscn").instantiate()
	favorites_container.add_child(favorite_panel)
	favorite_panel.set_filename(filename)
	
	var path = current_path + "/" + filename
	
	favorite_panel.set_filepath(path)
	favorite_panel.open_pressed.connect(_on_favorite_panel_open_pressed.bind(favorite_panel))
	favorite_panel.delete_pressed.connect(_on_favorite_panel_delete_pressed.bind(favorite_panel))
	
	if DirAccess.dir_exists_absolute(path):
		favorite_panel.set_color(Color(0.914, 0.553, 0.192))
	
	Globals.add_favorite(filename, path)
	Globals.save_favorites()


func _on_favorite_panel_open_pressed(panel: PanelContainer) -> void:
	var path = panel.get_filepath()
	if path == "":
		return
	if DirAccess.dir_exists_absolute(path):
		set_current_path(path)
		load_files(path, search_term)
	else:
		OS.shell_open(path)


func _on_favorite_panel_delete_pressed(panel: PanelContainer) -> void:
	var filename = panel.get_filename()
	Globals.remove_favorite(filename)
	Globals.save_favorites()
	panel.queue_free()


func _on_search_line_text_changed(new_text: String) -> void:
	search_term = new_text.strip_edges()
	load_files(current_path, search_term)


func fuzzy_match(filename: String, pattern: String) -> bool:
	filename = filename.to_lower()
	pattern = pattern.to_lower()
	
	var i = 0
	for character in filename:
		if pattern[i] == character:
			i += 1
			if i >= pattern.length():
				return true
	return false


func _on_filter_line_text_changed(new_text: String) -> void:
	filter_term = new_text.strip_edges()
	load_files(current_path, search_term)
