extends Area2D

signal attr_detected(attrb_elemental)

func _on_AreaDetectPlayerWeaponAttrbs_area_entered(area: Area2D) -> void :
	var attrb_elemental: Array
	var current_set = VarsGlobal.game_data["player_current_set"]
	
	if area.identifier.begins_with("whip"):
		
		if VarsGlobal.game_data["player_ec_alloy_selected"][current_set] >= 0:
			
			var alloy_key = GVar.ALLOYS.keys()[
				VarsGlobal.game_data["player_ec_alloy_selected"][current_set] + 1
			]
			var alloy_data = CSVDBLoader.get_db("alloys_elements")[alloy_key]
			
			attrb_elemental = alloy_data["attrb_elemental"].split(",")
	
	elif area.from_circuit_action != "":
		var ec_action_data = CSVDBLoader.get_db("elemental_circuits")[
			area.from_circuit_action
		]
		attrb_elemental = ec_action_data["attrb_elemental"].split(",")
	
	elif (
		
		area.custom_attrb_elemental != ""
	):
		attrb_elemental = area.custom_attrb_elemental.split(",")

	if attrb_elemental.empty() == false:
		emit_signal("attr_detected", attrb_elemental)
