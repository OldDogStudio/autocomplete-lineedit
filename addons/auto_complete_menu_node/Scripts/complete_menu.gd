@tool
class_name CompleteMenu
extends Control

var edit: LineEdit ## the edit this menu applies to
const _NULL_VECTOR2D = Vector2(0.0, 0.0)

var use_edit_font_size: bool

#region position vars
var _edit_margin : int = 0
var _node_margin_y: float = 3.0
var _anchor_point : Vector2 ## position is calculated relative to edit by resize
#endregion

#region size vars
## defines the size of the menu, in relation to the edit
## if this was (1,1) the menu would have the same size as the edit
var _size_min : Vector2 = Vector2(100, 0)
var _size_max : Vector2
var _size_mult : Vector2 = Vector2(1, 4) 
var _node_size: float : 
	get:
		var size_y = 0
		for node in _visible_nodes:
			size_y += node.size.y
		size_y += (_visible_nodes.size()) * _node_margin_y
		return size_y
#endregion

#region style vars
var _main_direction : Enums.Direction ## main menu direction
var _grow_upwards : bool = false 
#endregion

#region containers
var _visible_nodes : Array[Control] ## all the term-nodes that are currently visible
var _all_nodes : Array[Control] ## all the term nodes, one for each term
var _all_active_terms : Array = [] ## all loaded terms in one array
#endregion

#region control_vars
var _is_in_focus : bool
var _is_in_selection : bool
#endregion

var _current_text : String = "" ## the text that is currently checked. Not entire edit text if whitespaces are there

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
func hide_menu(override: bool = false) -> void:
	if _is_in_selection and not override:
		return
	elif get_global_rect().has_point(get_global_mouse_position()) and not override:
		return
	self.visible = false
	_is_in_focus = false


## loads the [param terms] as new option nodes [br]
## if [param override_terms] is true all the prior existing terms are removed
func load_terms(terms: Array, override_terms: bool = false) -> void:
	if override_terms:
		_remove_terms(_all_active_terms)
	if terms:
		var option_scene = preload("res://addons/auto_complete_menu_node/Scenes/complete_option.tscn")
		var base_option = option_scene.instantiate()
		if use_edit_font_size:
			var theme_font_size = edit.get_theme_font_size("font_size")
			var label_settings_obj = base_option.get_node("CompleteText").label_settings
			if theme_font_size:
				label_settings_obj.font_size = theme_font_size
			else:
				label_settings_obj.font_size = edit.get_theme_default_font_size()
		for term: String in terms:
			if term in _all_active_terms:
				continue
			var option = base_option.duplicate()
			_option_holder.add_child(option)
			option.get_node("CompleteText").text = term
			option.get_node("Button").connect("option_chosen", _on_option_chosen)
			_all_nodes.append(option)
	
	_all_active_terms.append_array(terms)
	_refresh_nodes(_current_text)


## recalculates size and position
func resize(new_size: Vector2 = _NULL_VECTOR2D) -> void:
	if new_size == _NULL_VECTOR2D:
		new_size = Vector2(edit.size.x * _size_mult.x, min(edit.size.y * _size_mult.y, _node_size))
		new_size = _size_min.max(new_size)
	if _size_max:
		set_deferred("size", _size_max.min(new_size))
	else:
		set_deferred("size", new_size)
	_calc__anchor_point()
	position = _anchor_point


func set_transform_values(margin: int, min_size: Vector2, mult_size: Vector2) -> void:
	if margin:
		_edit_margin = margin
	if min_size:
		_size_min = min_size
	if mult_size:
		_size_mult = mult_size


func set_up_menu(placement_point: Vector2, direction_main: Enums.Direction, direction_sub: Enums.Direction, \
		maximum_size: Vector2, line_edit: LineEdit) -> void:
	edit = line_edit
	_main_direction = direction_main
	_anchor_point = placement_point
	_grow_upwards = direction_sub == Enums.Direction.NORTH
	
	_size_max = maximum_size
	resize(edit.size * _size_mult)
	
	edit.connect("text_changed", _refresh_nodes)
	_refresh_nodes("")


func show_menu(refresh: bool = true) -> void:
	self.visible = true
	if refresh:
		_refresh_nodes(_current_text)
	_is_in_focus = true
	_is_in_selection = false

#endregion


#region Private Functions
func _calc__anchor_point() -> void:
	match _main_direction:
		Enums.Direction.NORTH:
			_anchor_point = edit.global_position - Vector2(0, get_rect().size.y + _edit_margin)
		Enums.Direction.EAST:
			_anchor_point = Vector2(edit.get_global_rect().end.x + _edit_margin, edit.global_position.y)
			_anchor_point.y -= (get_rect().size.y - edit.size.y) if _grow_upwards else 0.
		Enums.Direction.SOUTH:
			_anchor_point = Vector2(edit.global_position.x, edit.get_global_rect().end.y + _edit_margin)
		Enums.Direction.WEST:
			_anchor_point = Vector2(edit.global_position.x - get_rect().size.x - _edit_margin, edit.global_position.y)
			_anchor_point.y -= (get_rect().size.y - edit.size.y) if _grow_upwards else 0.


func _compare_options(a: Control, b: Control) -> bool:
	var a_text = _get_option_text(a)
	var b_text = _get_option_text(b)
	
	var score = 0
	score = b_text.length() - a_text.length()
	score += b_text.find(_current_text) - a_text.find(_current_text)
	
	return score > 0


func _get_option_text(option: Control) -> String:
	return option.get_node("CompleteText").text


## applies the [param text] chosen in the menu to the edits text
## is called by the option_chosen signal in the option_button
func _on_option_chosen(text: String) -> void:
	var text_parts = edit.text.split(" ")
	var t_length = 0
	var whitespace_i = 0
	var new_column_pos = edit.text.length()
	for i in text_parts.size():
		t_length += text_parts[i].length()
		if _current_text == text_parts[i] and t_length + whitespace_i >= edit.caret_column:
			text_parts[i] = text
			new_column_pos = " ".join(PackedStringArray(text_parts.slice(0, i))).length() + text.length() + (0 if i == 0 else 1)
			break
		whitespace_i += 1
	edit.text = " ".join(PackedStringArray(text_parts))
	edit.grab_focus()
	edit.caret_column = new_column_pos
	hide_menu(true)


## sorts the nodes anew based on the new text and calls the reposition method
func _refresh_nodes(text: String) -> void:
	var terms = text.split(" ")
	var t_length = 0
	var whitespace_i = 0
	# split up the currently selection completion term by whitespaces
	for term in terms:
		t_length += term.length()
		if t_length + whitespace_i >= edit.caret_column:
			text = term
			break
		whitespace_i += 1
	_current_text = text
	
	if text.is_empty():
		_visible_nodes = _all_nodes
	else:
		_visible_nodes = _all_nodes.filter(func(x): return text in _get_option_text(x))
		for node in _all_nodes.filter(func(x): return not text in _get_option_text(x)):
			node.visible = false
	_visible_nodes.assign(_visible_nodes.map(func(x): x.visible = true; return x))
	
	_visible_nodes.sort_custom(_compare_options)
	
	_reposition_nodes(_visible_nodes)
	if _grow_upwards:
		_scroll_container.set_deferred("scroll_vertical", _scroll_container.get_v_scroll_bar().max_value)
	
	resize()
	if _visible_nodes:
		if _grow_upwards:
			edit.focus_neighbor_top = _visible_nodes[0].get_node("Button").get_path()
			_visible_nodes[0].get_node("Button").focus_neighbor_bottom = edit.get_path()
		else:
			edit.focus_neighbor_bottom = _visible_nodes[0].get_node("Button").get_path()
			_visible_nodes[0].get_node("Button").focus_neighbor_top = edit.get_path()
	show_menu(false)


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
	
	_refresh_nodes(_current_text)


## positions the nodes, based on the order they are given
func _reposition_nodes(ordered_nodes: Array[Control]) -> void:
	_visible_nodes = ordered_nodes
	var holder_size = _node_size
	var grow_indicator = -1 if _grow_upwards else 1 # used instead of if-else everytime addition/subtraction is used
	_option_holder.set_custom_minimum_size(Vector2(0, holder_size))
	var current_position = Vector2(0, holder_size) if _grow_upwards else Vector2(0, 0)
	for node in ordered_nodes:
		node.position = current_position
		node.position.y -= node.size.y if _grow_upwards else 0.
		node.set_deferred("size", Vector2(_option_holder.size.x, node.size.y))
		current_position.y += grow_indicator * (node.size.y + _node_margin_y)

#endregion


#region Signal Receivers
## makes it so the optionmenu can be navigated with the arrow keys, by interrupting default lineEdit key behavior
func _input(event):
	if event is InputEventKey:
		var select_nav_button = "ui_up" if _grow_upwards else "ui_down"
		var back_nav_button = "ui_down" if _grow_upwards else "ui_up"
		var edit_focus_neighbor = edit.focus_neighbor_top if _grow_upwards else edit.focus_neighbor_bottom
	
		if not edit.has_focus():
			return
	
		if event.is_action_pressed(select_nav_button) and not _is_in_selection and _visible_nodes:
			get_viewport().set_input_as_handled()
			_is_in_selection = true
			get_node(edit_focus_neighbor).grab_focus()
		
		if event.is_action_pressed(back_nav_button) and _is_in_selection:
			_is_in_selection = false
	
	if event is InputEventMouseButton:
		if event.is_released():
			if not (get_global_rect().has_point(get_global_mouse_position()) or edit.get_global_rect().has_point(get_global_mouse_position())):
				if edit.has_focus():
					edit.release_focus()
				else:
					hide_menu(true)

#endregion
