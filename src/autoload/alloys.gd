extends Node

var alloys_dict: Dictionary

func _ready() -> void :
	
	alloys_dict = CSVDBLoader.get_db("alloys_elements")

func get_attrbs_physical(_alloy_ide: int) -> int:
	
	return 0

func get_attrbs_elemental(alloy_ide: int) -> Array:
	
	var att_list: Array
	
	for at in alloys_dict[get_alloy_string(alloy_ide)]["attrb_elemental"].split(","):
		att_list.append(at.to_upper())

	return att_list

func get_alloy_string(alloy_ide: int) -> String:
	return GVar.ALLOYS.keys()[alloy_ide]
