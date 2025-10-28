extends PanelContainer

signal open_pressed
signal delete_pressed
signal rename_pressed
signal favorite_pressed

@onready var file_name: Label = $MarginContainer/VBoxContainer/FileName


func set_filename(filename: String) -> void:
	file_name.text = filename
	file_name.tooltip_text = filename


func _on_open_pressed() -> void:
	open_pressed.emit()


func _on_rename_pressed() -> void:
	rename_pressed.emit()


func _on_delete_pressed() -> void:
	delete_pressed.emit()


func _on_favorite_pressed() -> void:
	favorite_pressed.emit()
