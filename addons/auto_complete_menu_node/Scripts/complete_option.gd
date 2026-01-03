@tool
extends ColorRect

signal option_chosen(option_text)



func _on_button_pressed() -> void:
	var label : Label = find_child("CompleteText")
	option_chosen.emit(label.text)
