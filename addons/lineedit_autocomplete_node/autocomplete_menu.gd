@tool
class_name CompleteMenu
extends Control

enum OPTION_CONTAINERS {ALL, VISIBLE}

const _NULL_VECTOR2D = Vector2(0.0, 0.0)

#region position vars
var _edit_margin : int = 0
var _node_margin_y: float = 3.0
var _anchor_point : Vector2 ## position is calculated relative to edit by resize   -Lenrow
#endregion

#region size vars
## defines the size of the menu, in relation to the edit if this was (1,1) the menu would have the
## same size as the edit   -Lenrow
var _size_min : Vector2 = Vector2(100, 0)
var _size_max : Vector2
var _size_mult : Vector2 = Vector2(1, 4) 
var _node_size_y: float : 
	get:
		var size_y = 0
		for node in _visible_nodes:
			size_y += node.size.y
		size_y += (_visible_nodes.size()) * _node_margin_y
		return size_y
#endregion

#region style vars
var _font_size : int
var _main_direction : Enums.Direction ## main menu direction   -Lenrow
var _grow_upwards : bool = false 
#endregion

#region containers
var _lineedit_path : NodePath
var _visible_nodes : Array[Control] ## all the term-nodes that are currently visible   -Lenrow
var _all_nodes : Array[Control] ## all the term nodes, one for each term   -Lenrow
var _all_active_terms : Array = [] ## all loaded terms in one array   -Lenrow
#endregion

#region control_vars
var _is_in_focus : bool
var _is_in_selection : bool
#endregion

## the text that is currently checked. Not entire edit text if whitespaces are there   -Lenrow
var _current_text : String = ""

@onready var _option_holder : Control = find_child("OptionHolder")
@onready var _scroll_container : ScrollContainer = find_child("ScrollContainer")



#region Engine Functions
func _init():
	pass


func _ready() -> void:
	pass


#func _process(delta: float) -> void:
	#pass

#endregion


#region Public Functions
func apply_option_formatting() -> void:
	pass


func get_term_option_buttons(list: OPTION_CONTAINERS) -> Array:
	var source : Array
	var result = []
	match list:
		OPTION_CONTAINERS.ALL:
			source = _all_nodes
		OPTION_CONTAINERS.VISIBLE:
			source = _visible_nodes
		_:
			pass
	
	for option in source:
		result.append(option)
	
	return result


func hide_menu(override: bool = false) -> void:
	if _is_in_selection and not override:
		return
	elif get_global_rect().has_point(get_global_mouse_position()) and not override:
		return
	self.visible = false
	_is_in_focus = false


## loads the [param terms] as new option nodes [br]
## if [param override_terms] is true all the prior existing terms are removed
## -Lenrow^^
func load_terms(terms: Array, override_terms: bool = false) -> void:
	if override_terms:
		_remove_terms(_all_active_terms)
	if terms:
		var option_scene = preload("res://addons/lineedit_autocomplete_node/autocomplete_option.tscn")
		var base_option = option_scene.instantiate()
		var label_settings_obj = base_option.get_node("CompleteText").label_settings
		label_settings_obj.font_size = _font_size
		for term: String in terms:
			if term in _all_active_terms:
				continue
			var option = base_option.duplicate()
			_option_holder.add_child(option)
			option.get_node("CompleteText").text = term
			#option.get_node("Button").option_chosen.connect(_on_option_chosen)
			_all_nodes.append(option)
	
	_all_active_terms.append_array(terms)
	refresh_nodes(_current_text)


## applies the [param text] chosen in the menu to the edits text
## is called by the option_chosen signal in the option_button
func on_option_chosen(option_text: String, whole_line_text: String, caret_col: int) -> Dictionary:
	var text_parts = whole_line_text.split(" ")
	var t_length = 0
	var whitespace_i = 0
	var new_column_pos = whole_line_text.length()
	for i in text_parts.size():
		t_length += text_parts[i].length()
		if _current_text == text_parts[i] and t_length + whitespace_i >= caret_col:
			text_parts[i] = option_text
			new_column_pos = " ".join(PackedStringArray(text_parts.slice(0, i))).length() + \
					option_text.length() + (0 if i == 0 else 1)
			break
		whitespace_i += 1
	var return_text = " ".join(PackedStringArray(text_parts))
	hide_menu(true)
	return {"text": return_text, "caret": new_column_pos}
	

# Recalculates size and position when container or associate LineEdit changes.
# External use.
func resize_for_lineedit(line_size: Vector2, line_gpos: Vector2, line_grect: Rect2) -> void:
	var new_size = Vector2(line_size.x * _size_mult.x, min(line_size.y * _size_mult.y, _node_size_y))
	new_size = _size_min.max(new_size)
	if _size_max:
		set_deferred("size", _size_max.min(new_size))
	else:
		set_deferred("size", new_size)
	call_deferred("_apply_anchor_point", line_size, line_gpos, line_grect)
	position = _anchor_point


## sorts the nodes anew based on the new text and calls the reposition method
## Lenrow^
func refresh_nodes(text: String, caret_column: int = 0) -> void:
	var terms = text.split(" ")
	var t_length = 0
	var whitespace_i = 0
	# split up the currently selection completion term by whitespaces
	for term in terms:
		t_length += term.length()
		if t_length + whitespace_i >= caret_column:
			text = term
			break
		whitespace_i += 1
	_current_text = text
	
	if text.is_empty():
		_visible_nodes = _all_nodes
	else:
		_visible_nodes = _all_nodes.filter(func(x): return text.to_lower() in _get_option_text(x).to_lower())
		for node in _all_nodes.filter(func(x): return not text.to_lower() in _get_option_text(x).to_lower()):
			node.visible = false
	_visible_nodes.assign(_visible_nodes.map(func(x): x.visible = true; return x))
	
	_visible_nodes.sort_custom(_compare_options)
	
	_reposition_nodes(_visible_nodes)
	if _grow_upwards:
		_scroll_container.set_deferred("scroll_vertical", _scroll_container.get_v_scroll_bar().max_value)
	
	if _visible_nodes:
		if _grow_upwards:
			get_node(_lineedit_path).focus_neighbor_top = _visible_nodes[0].get_node("Button").get_path()
			_visible_nodes[0].get_node("Button").focus_neighbor_bottom = _lineedit_path
		else:
			get_node(_lineedit_path).focus_neighbor_bottom = _visible_nodes[0].get_node("Button").get_path()
			_visible_nodes[0].get_node("Button").focus_neighbor_top = _lineedit_path
	
	# part of show_menu(), duplicated here to avoid needing to stop recursion.
	self.visible = true
	_is_in_focus = true
	_is_in_selection = false


func set_transform_values(margin: int, min_size: Vector2, mult_size: Vector2) -> void:
	if margin:
		_edit_margin = margin
	if min_size:
		_size_min = min_size
	if mult_size:
		_size_mult = mult_size


func set_up_menu(placement_point: Vector2, direction_main: Enums.Direction, direction_sub: Enums.Direction, \
		maximum_size: Vector2, line_size: Vector2, line_path: NodePath, font_size: int) -> void:
	_main_direction = direction_main
	_anchor_point = placement_point
	_grow_upwards = direction_sub == Enums.Direction.NORTH
	_size_max = maximum_size
	_lineedit_path = line_path
	_font_size = font_size
	
	_resize(line_size * _size_mult)
	refresh_nodes("")


func show_menu(caret_col: int) -> void:
	self.visible = true
	refresh_nodes(_current_text, caret_col)
	_is_in_focus = true
	_is_in_selection = false

#endregion


#region Private Functions
func _apply_anchor_point(line_size: Vector2, line_gpos: Vector2, line_grect: Rect2) -> void:
	_calc_anchor_point(line_size, line_gpos, line_grect)
	position = _anchor_point


func _calc_anchor_point(line_size: Vector2, line_gpos: Vector2, line_grect: Rect2) -> void:
	match _main_direction:
		Enums.Direction.NORTH:
			_anchor_point = line_gpos - Vector2(0, get_rect().size.y + _edit_margin)
		Enums.Direction.EAST:
			_anchor_point = Vector2(line_grect.end.x + _edit_margin, line_gpos.y)
			_anchor_point.y -= (get_rect().size.y - line_size.y) if _grow_upwards else 0
		Enums.Direction.SOUTH:
			_anchor_point = Vector2(line_gpos.x, line_grect.end.y + _edit_margin)
		Enums.Direction.WEST:
			_anchor_point = Vector2(line_gpos.x - get_rect().size.x - _edit_margin, line_gpos.y)
			_anchor_point.y -= (get_rect().size.y - line_size.y) if _grow_upwards else 0


func _compare_options(a: Control, b: Control) -> bool:
	var a_text = _get_option_text(a)
	var b_text = _get_option_text(b)
	
	var score = 0
	score = b_text.length() - a_text.length()
	score += b_text.find(_current_text) - a_text.find(_current_text)
	
	return score > 0


func _get_option_text(option: Control) -> String:
	return option.get_node("CompleteText").text


func _remove_terms(terms: Array) -> void:
	var remove_nodes = []
	for node in _all_nodes:
		if _get_option_text(node) in terms:
			remove_nodes.append(node)
	
	_visible_nodes = _visible_nodes.filter(func(x): return not x in remove_nodes)
	_all_nodes = _all_nodes.filter(func(x): return not x in remove_nodes)
	_all_active_terms = _all_active_terms.filter(func(x): return not x in terms)
	for node in remove_nodes:
		node.queue_free()
	
	refresh_nodes(_current_text)


## positions the nodes, based on the order they are given
## Lenrow^
func _reposition_nodes(ordered_nodes: Array[Control]) -> void:
	_visible_nodes = ordered_nodes
	var holder_size = _node_size_y
	var grow_indicator = -1 if _grow_upwards else 1 # used instead of if-else everytime addition/subtraction is used
	_option_holder.set_custom_minimum_size(Vector2(0, holder_size))
	var current_position = Vector2(0, holder_size) if _grow_upwards else Vector2(0, 0)
	for node in ordered_nodes:
		node.position = current_position
		node.position.y -= node.size.y if _grow_upwards else 0.
		node.set_deferred("size", Vector2(_option_holder.size.x, node.size.y))
		current_position.y += grow_indicator * (node.size.y + _node_margin_y)


## recalculates size and position -Lenrow
# Internal use
func _resize(new_size: Vector2) -> void:
	if _size_max:
		set_deferred("size", _size_max.min(new_size))
	else:
		set_deferred("size", new_size)

#endregion


#region Signal Receivers
## makes it so the optionmenu can be navigated with the arrow keys, by interrupting 
## default lineEdit key behavior
## Lenrow^
func _input(event):
	if event is InputEventKey:
		var select_nav_button = "ui_up" if _grow_upwards else "ui_down"
		var back_nav_button = "ui_down" if _grow_upwards else "ui_up"
		var line_focus_neighbor = get_node(_lineedit_path).focus_neighbor_top if _grow_upwards \
				else get_node(_lineedit_path).focus_neighbor_bottom
	
		if not get_node(_lineedit_path).has_focus():
			return
	
		if event.is_action_pressed(select_nav_button) and not _is_in_selection and _visible_nodes:
			get_viewport().set_input_as_handled()
			_is_in_selection = true
			get_node(line_focus_neighbor).grab_focus()
		
		if event.is_action_pressed(back_nav_button) and _is_in_selection:
			_is_in_selection = false
	
	if event is InputEventMouseButton:
		if event.is_released():
			if not (get_global_rect().has_point(get_global_mouse_position()) \
					or get_node(_lineedit_path).get_global_rect().has_point(get_global_mouse_position())):
				if get_node(_lineedit_path).has_focus():
					get_node(_lineedit_path).release_focus()
				else:
					hide_menu(true)

#endregion
