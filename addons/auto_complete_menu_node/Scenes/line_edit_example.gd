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
@onready var _autocomplete : AutoCompleteAssistant = find_child("AutoCompleteAssistant")
@onready var _makes_line: LineEdit = find_child("MakesLineEdit")
@onready var _models_line: LineEdit = find_child("ModelsLineEdit")



# ########################################################################### #
#    E N G I N E    F U N C T I O N S
# ########################################################################### #
#region
func _init():
	pass


func _ready() -> void:
	# setup MakeLineEdit
	_autocomplete.add_lineedit(_makes_line, [_FORD, _HONDA, _MAZDA, _TOYOTA])
	# setup ModelsLineEdit
	_autocomplete.add_lineedit(_models_line, [])


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
	
	_autocomplete.load_terms(_models_line, array, path, true)

#endregion
