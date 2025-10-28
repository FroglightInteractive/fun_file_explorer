extends HFlowContainer

@onready var path_label: Label = $"../../HBoxContainer/VBoxContainer/PathPanel/VBoxContainer/PathLabel"

var current_path: String


func _ready() -> void:
	set_current_path(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	load_files(current_path)


func set_current_path(new_path: String) -> void:
	new_path = new_path.replace("//", "/")
	current_path = new_path
	path_label.text = new_path


func load_files(path: String) -> void:
	for child in get_children():
		child.queue_free()
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			var file_button = preload("res://Panels/FilePanel/file_panel.tscn").instantiate()
			add_child(file_button)
			file_button.set_filename(filename)
			file_button.favorite_pressed.connect(_on_file_favorite_pressed.bind(filename))
			if dir.current_is_dir():
				file_button.open_pressed.connect(_on_folder_opened.bind(filename))
			else:
				file_button.open_pressed.connect(_on_file_opened.bind(filename))
			filename = dir.get_next()
	else:
		print("no directory found")


func _on_file_opened(filename: String) -> void:
	var abs_path = current_path + "/" + filename
	OS.shell_open(abs_path)


func _on_folder_opened(foldername: String) -> void:
	var abs_path = current_path + "/" + foldername
	set_current_path(abs_path)
	load_files(current_path)


func _on_folder_up_pressed() -> void:
	var new_path = current_path.get_base_dir()
	set_current_path(new_path)
	load_files(current_path)


func _on_file_favorite_pressed(filename: String) -> void:
	print("favorite: " + filename)
