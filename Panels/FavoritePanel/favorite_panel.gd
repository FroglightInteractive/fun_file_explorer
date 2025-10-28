extends PanelContainer

signal open_pressed
signal delete_pressed

@onready var file_name: Label = $MarginContainer/VBoxContainer/FileName

var path: String = ""


func set_filename(filename: String) -> void:
	file_name.text = filename
	file_name.tooltip_text = filename


func set_filepath(new_path: String) -> void:
	path = new_path


func get_filepath() -> String:
	return path


func _on_open_pressed() -> void:
	open_pressed.emit()


func _on_delete_pressed() -> void:
	delete_pressed.emit()
