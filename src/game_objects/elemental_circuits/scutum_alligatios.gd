extends Node2D

var mp_cost: int

func _ready() -> void :
	
	VarsGlobal.GameInterface.connect(
		"alloy_changed", self, "_player_set_changed"
	)
	VarsGlobal.GameInterface.connect(
		"set_changed", self, "_player_set_changed"
	)
	
	mp_cost = ElementalCircuits.get_circuit_mp_cost(
		GVar.EC_MODE.ACTION, GVar.EC_ACTION.SCUTUM_ALLIGATIOS
	)
	
	
	var current_set = VarsGlobal.game_data["player_current_set"]
	if VarsGlobal.game_data["player_ec_alloy_selected"][current_set] >= 0:
		
		var alloy_key = GVar.ALLOYS.keys()[
			VarsGlobal.game_data["player_ec_alloy_selected"][current_set] + 1
		]
		var alloy_data = CSVDBLoader.get_db("alloys_elements")[alloy_key]
		
		$EcScutumAlligatios / HitboxPlayer.custom_attrb_physical = alloy_data["attrb_physical"]
		$EcScutumAlligatios / HitboxPlayer.custom_attrb_elemental = alloy_data["attrb_elemental"]

func _player_set_changed() -> void :
	queue_free()

func _on_TimerDecreaseMana_timeout() -> void :
	

	
	pass
