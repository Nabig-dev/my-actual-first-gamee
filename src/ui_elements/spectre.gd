extends HBoxContainer

export (String, "FE", "CU", "AG", "SN", "AU", "HG", "PB") var element = "PB"
export var custom_spectre: bool
export var auto_start_see_spectre: bool

var _colors_elements: Dictionary = {
	"FE": ["BL", "OR", "YE", "GR", "CY", "PR"], 
	"CU": ["BL", "OR", "YE", "BL", "CY", "BL"], 
	"AG": ["BL", "BL", "BL", "GR", "BL", "PR"], 
	"SN": ["RD", "BL", "BL", "GR", "BL", "PR"], 
	"AU": ["RD", "BL", "YE", "GR", "CY", "PR"], 
	"HG": ["BL", "BL", "YE", "GR", "BL", "PR"], 
	"PB": ["RD", "OR", "YE", "GR", "CY", "PR"]
}


var _colors: Dictionary = {
	"RD": "e30013", 
	"OR": "ff8a00", 
	"YE": "f6ff00", 
	"GR": "3aff17", 
	"CY": "05ffff", 
	"PR": "7f64ff", 
	"BL": "000000"
}

var hash_colors: Dictionary

func _ready() -> void :
	if auto_start_see_spectre == true:
		update_spectre(true)


func get_spectre_hashes(elemnt_custom: String = element) -> Dictionary:
	var _hash_clrs: Dictionary = {
		"RD": hash_word_to_number(VarsGlobal.game_data["save_name"], elemnt_custom, "RD"), 
		"OR": hash_word_to_number(VarsGlobal.game_data["save_name"], elemnt_custom, "OR"), 
		"YE": hash_word_to_number(VarsGlobal.game_data["save_name"], elemnt_custom, "YE"), 
		"GR": hash_word_to_number(VarsGlobal.game_data["save_name"], elemnt_custom, "GR"), 
		"CY": hash_word_to_number(VarsGlobal.game_data["save_name"], elemnt_custom, "CY"), 
		"PR": hash_word_to_number(VarsGlobal.game_data["save_name"], elemnt_custom, "PR")
	}
	
	for cl in _hash_clrs.keys():
		if cl in _colors_elements[elemnt_custom]:
			pass
		
		else:
			_hash_clrs[cl] = 0
	return _hash_clrs


func get_current_spectre_hashes() -> Dictionary:
	var _hash_clrs: Dictionary = {
		"RD": 0, 
		"OR": 0, 
		"YE": 0, 
		"GR": 0, 
		"CY": 0, 
		"PR": 0
	}
	
	var nodes_list: Array = get_children()
	for nod in nodes_list:
		if nod.name.begins_with("ClrRect"):
			
			
			for nc in _colors.keys():
				if nod.color == Color(_colors[nc]) and nc != "BL":
					_hash_clrs[nc] += 1

	return _hash_clrs

func update_spectre(userealhash: bool = true) -> void :
	
	if userealhash == true:
		hash_colors = get_spectre_hashes()
		
	
	var string_result: String
	
	
	var _clrs_elements: Array = _colors_elements[element]
	
	
	if custom_spectre == true:
		_clrs_elements = _colors_elements["PB"]
	
	for c in _clrs_elements:
		
		if c == "BL":
			
			string_result += "BL-BL-BL-"
		
		else:

			var hash_color: int = hash_colors[c]
			
			var colors_str: String
			for _n in range(hash_color):
				
				colors_str += c + "-"
			
			for _n in range(3 - hash_color):
				colors_str += "BL-"
			
			string_result += colors_str

	var nodes_list: Array = get_children()
	var clr_list: Array = string_result.split("-", false)
	
	var i = 0
	for nod in nodes_list:
		if nod.name.begins_with("ClrRect"):
			nod.color = _colors[clr_list[i]]
			i += 1

func hash_word_to_number(word: String = "XANDRIA", _element: String = element, color: String = "BLACK") -> int:
	var hash_value: int = 0
	
	for c in word + _element + color:
		hash_value += ord(c)
	
	var result = hash_value % 4
	return result
