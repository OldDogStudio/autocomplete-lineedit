extends Control

const _FORD = "Ford"
const _HONDA = "Honda"
const _MAZDA = "Mazda"
const _TOYOTA = "Toyota"

@onready var _autocomplete_make_model = find_child("AutoCompleteAssistant")
@onready var _autocomplete_power_trans = find_child("AutoCompleteAssistant2")
@onready var _makes_line: LineEdit = find_child("MakesLineEdit")
@onready var _models_line: LineEdit = find_child("ModelsLineEdit")
@onready var _power_line: LineEdit = find_child("PowerLineEdit")
@onready var _trans_line: LineEdit = find_child("TransmissionLineEdit")



#region Engine Functions
func _init():
	pass


func _ready() -> void:
	# setup MakeLineEdit
	_autocomplete_make_model.add_lineedit(_makes_line, [_FORD, _HONDA, _MAZDA, _TOYOTA])
	# setup ModelsLineEdit
	_autocomplete_make_model.add_lineedit(_models_line, [])
	# setup PowerLineEdit
	_autocomplete_power_trans.add_lineedit(_power_line, ["Gasoline Engine", "Diesel Engine", "Electric", "Hybrid"])
	# setup TransmissionLineEdit
	_autocomplete_power_trans.add_lineedit(_trans_line, ["Discrete Automatic", "Continuously-Variable Automatic", "Manual"])


#func _process(delta: float) -> void:
	#pass

#endregion


#region Public Functions

#endregion


#region Private Functions

#endregion


#region Signal Receivers
func _on_makes_line_edit_text_submitted(new_text: String) -> void:
	var array = []
	var path = ""
	match _makes_line.text:
		_FORD:				# (another) array example
			array = ["Focus", "Model T", "Ranger"]
		_HONDA:				# json dictionary example
			path = "res://addons/lineedit_autocomplete_node/Example/honda_models.json"
		_MAZDA:				# json array example
			path = "res://addons/lineedit_autocomplete_node/Example/mazda_models.json"
		_TOYOTA:			# txt example
			path = "res://addons/lineedit_autocomplete_node/Example/toyota_models.txt"
	
	_autocomplete_make_model.load_terms(_models_line, array, path, true)

#endregion
