extends Control

# signals

# enums

# constants
const _FORD = "Ford"
const _HONDA = "Honda"
const _MAZDA = "Mazda"
const _TOYOTA = "Toyota"

# export vars

# public vars

# private vars

# onready vars
@onready var _autocomplete_make_model : AutoCompleteAssistant = find_child("AutoCompleteAssistant")
@onready var _autocomplete_power_trans : AutoCompleteAssistant = find_child("AutoCompleteAssistant2")
@onready var _makes_line: LineEdit = find_child("MakesLineEdit")
@onready var _models_line: LineEdit = find_child("ModelsLineEdit")
@onready var _power_line: LineEdit = find_child("PowerLineEdit")
@onready var _trans_line: LineEdit = find_child("TransmissionLineEdit")



# ########################################################################### #
#    E N G I N E    F U N C T I O N S
# ########################################################################### #
#region
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


# ################################################################################################ #
#    P U B L I C    F U N C T I O N S
# ################################################################################################ #
#region

#endregion


# ################################################################################################ #
#    P R I V A T E    F U N C T I O N S
# ################################################################################################ #
#region

#endregion


# ########################################################################### #
#    S I G N A L    R E C E I V E R S
# ########################################################################### #
#region
func _on_makes_line_edit_text_submitted(new_text: String) -> void:
	var array = []
	var path = ""
	match _makes_line.text:
		_FORD:				# (another) array example
			array = ["Focus", "Model T", "Ranger"]
		_HONDA:				# json dictionary example
			path = "res://addons/auto_complete_menu_node/Scenes/honda_models.json"
		_MAZDA:				# json array example
			path = "res://addons/auto_complete_menu_node/Scenes/mazda_models.json"
		_TOYOTA:			# txt example
			path = "res://addons/auto_complete_menu_node/Scenes/toyota_models.txt"
	
	_autocomplete_make_model.load_terms(_models_line, array, path, true)

#endregion
