@tool
class_name AutoCompleteAssistant
extends Node

# ########################################################################### #
#    THIS IS A FORKED PROJECT. The original source is code from "Lenrow". Any
#    retained comments have been accredited to Lenrow.
# ########################################################################### #

## "defines in which node the menu should be located. [br]
## This node has to contain the line_edit(s) you want it to appear for. [br]
## Not necessarily as a parent but the edits must intersect with its global_rect
## since the menu will not cut out of this nodes boundaries"
## -Lenrow^^
@export var menu_location_node : Control

@export_group("Menu Transform Settings")
@export var margin : float = 0
@export var size_min : Vector2 = Vector2(100, 0)
@export var size_mult : Vector2 = Vector2(1, 4)

@export_group("Disabled Menu Directions")
@export var disable_north : bool
@export var disable_east : bool
@export var disable_south : bool
@export var disable_west : bool

@export_group("UI parameters")
@export var use_edit_font_size : bool

# key: LineEdit reference			inner-keys: string labels
# inner-value1: an array of Strings
# inner-value2: CompleteMenu reference
# {LineEdit-1: {"terms": ["term1", "term2",], "menu": CompleteMenu-1}, LineEdit-2: {"terms": ["term3...
var _lineedit_data : Dictionary = {}
var _complete_menu : Resource = preload("res://addons/auto_complete_menu_node/Scenes/complete_menu.tscn")



# ########################################################################### #
#    E N G I N E    F U N C T I O N S
# ########################################################################### #
#region
func _ready() -> void:
	pass

#endregion


# ################################################################################################ #
#    P U B L I C    F U N C T I O N S
# ################################################################################################ #
#region
# Adds LineEdit to provide autocompletion for and subsequently creates the CompleteMenu for it
func add_lineedit(line: LineEdit, terms: Array, source: String = ""):
	if _lineedit_data.has(line):
		assert(false, "ERROR: Trying to add LineEdit which AutoCompleAssistant already has.")
		return
	
	# CompleteMenu component
	var new_menu = _create_complete_menu(line)
	# Connect signals
	menu_location_node.resized.connect(new_menu.resize)
	new_menu.resized.connect(new_menu.resize)
	line.focus_entered.connect(new_menu.show_menu)
	line.focus_exited.connect(new_menu.hide_menu)
	line.text_changed.connect(_on_text_changed.bind(line))
	
	# Terms component
	var file_terms = []
	var final_terms = []
	if not terms.is_empty():
		final_terms = terms.duplicate()
	if not source.is_empty():
		file_terms = _load_terms_from_file(source)
	if not file_terms.is_empty():
		final_terms.append_array(file_terms)
	
	# Update dictionary
	_lineedit_data[line] = {"terms": final_terms, "menu": new_menu}
	
	# Populate menu
	new_menu.load_terms(final_terms)
	
	# Hide until needed
	new_menu.hide_menu(true)


func load_terms(line: LineEdit, terms: Array, source: String = "", replace: bool = false) -> void:
	var final_terms = []
	if not terms.is_empty():
		final_terms.append_array(terms)
	if not source.is_empty():
		if source.is_absolute_path() or source.is_relative_path():
			final_terms.append_array(_load_terms_from_file(source))
	
	if replace:
		_lineedit_data[line]["terms"] = final_terms
	else:
		_lineedit_data[line]["terms"].append_array(final_terms)
	_lineedit_data[line]["menu"].load_terms(final_terms)


# Remove a LineEdit from autocompletion support.
func remove_edit(line: LineEdit):
	if _lineedit_data.has(line):
		_lineedit_data[line]["menu"].queue_free()
		_lineedit_data.erase(line)
	else:
		assert(false, "ERROR: trying to remove an edit that has no complete menu")

#endregion


# ################################################################################################ #
#    P R I V A T E    F U N C T I O N S
# ################################################################################################ #
#region
func _create_complete_menu(line: LineEdit) -> CompleteMenu:
	var new_menu: CompleteMenu = _complete_menu.instantiate()
	add_child(new_menu)
	
	# Set parameters
	var location_info = _get_location_boundaries(line) # 0 is main direction as int (from enum) 1 is sub-direction so if north or south greater (for east-west) is max_size vector
	var direction = location_info[0]
	var placement_point = _get_menu_placement_vec(line, direction)
	new_menu.use_edit_font_size = use_edit_font_size
	new_menu.set_transform_values(margin, size_min, size_mult)
	new_menu.set_up_menu(placement_point, direction, location_info[1], location_info[2], line)
	
	return new_menu


## calculates the free space available in all 4 directions of the LineEdit rect and the 
## menu_location_node rect. If successful it returns a dictionary with the values
## -Lenrow^^
func _get_location_boundaries(line: LineEdit):
	var disable_direction_arr = [disable_north, disable_east, disable_south, disable_west]

	if not menu_location_node or not line:
		assert(false, "ERROR: NODE CONFIGURATION ERROR; LOCATION_NODE OR EDIT_NODE ARE NULL!")
		return null
	
	var location_rect = menu_location_node.get_global_rect()
	var edit_rect = line.get_global_rect()
	if not location_rect.intersects(edit_rect):
		assert(false, "ERROR: NODE CONFIGURATION ERROR; EDIT NOT WITHIN LOCATION_NODE")
		return null
	
	var direction_rects = Helpers.subtract_rects(location_rect, edit_rect)
	var values = direction_rects["Values"]
	var max_value = 0
	var max_index = 0
	for i in values.size():
		var current_rect = values[i]
		if max_value <= current_rect.get_area() and not disable_direction_arr[i]:
			max_value = current_rect.get_area()
			max_index = i
	
	var max_size = direction_rects["Values"][max_index].size
	if max_index == 0 or max_index == 2:
		max_size.x = (location_rect.size - (edit_rect.position - location_rect.position)).x
	else:
		max_size.y = (location_rect.size - (edit_rect.position - location_rect.position)).y
	var vertical_direction = Enums.Direction.NORTH if values[0].size.y > values[2].size.y else Enums.Direction.SOUTH

	return [Enums.Direction[direction_rects.keys()[max_index]], vertical_direction, max_size]


func _get_menu_placement_vec(line: LineEdit, direction):
	var edit_rect = line.get_global_rect()
	var result
	match direction:
		Enums.Direction.EAST:
			result = Vector2(edit_rect.end.x, edit_rect.position.y)
		Enums.Direction.SOUTH:
			result = Vector2(edit_rect.position.x, edit_rect.end.y)
		_:
			result = edit_rect.position
		
	# TODO: add margins or stuff
	return result


func _load_terms_from_file(file_path: String) -> Array:
	var result = []
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var terms = file.get_as_text()
		file.close()
		var json_object = JSON.parse_string(terms)
		if json_object != null:
			if typeof(json_object) == TYPE_ARRAY:
				result = json_object
			elif typeof(json_object) == TYPE_DICTIONARY:
				if json_object.has("terms"):
					result = json_object["terms"]
		else:
			terms = terms.split("\n")
			result = Array(terms).filter(func(line): return not line.is_empty())
			#result = terms.split("\n").filter(func(line): return not line.is_empty())
	else:
		assert(false, "ERROR: terms file path is invalid: %s" % file_path)
	
	return result


#endregion


# ########################################################################### #
#    S I G N A L    R E C E I V E R S
# ########################################################################### #
#region
# If LMB selects CompleteMenu button, LineEdit.text_changed is emitted but not LineEdit.text_submitted.
# Use this receiver to trigger any 
func _on_text_changed(new_text: String, line: LineEdit) -> void:
	if new_text in _lineedit_data[line]["terms"]:
		line.text_submitted.emit(new_text)

#endregion
