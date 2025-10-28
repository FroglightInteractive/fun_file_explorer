extends Button


func _make_custom_tooltip(for_text: String) -> Object:
	var tooltip = preload("res://Panels/custom_tooltip.tscn").instantiate()
	tooltip.get_node("MarginContainer/Label").text = for_text
	return tooltip
