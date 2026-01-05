@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("AutoCompleteLineEdit", "Node", \
			preload("res://addons/lineedit_autocomplete_node/lineedit_autocomplete_assistant.gd"), \
			preload("res://addons/lineedit_autocomplete_node/Assets/lineedit-autocomplete-icon.png"))


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
