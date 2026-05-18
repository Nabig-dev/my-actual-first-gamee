extends Node

func debug_data() -> void :
	
	VarsGlobal.game_data["player_atk"] = 19
	VarsGlobal.game_data["player_def"] = 13
	VarsGlobal.game_data["player_int"] = 19
	VarsGlobal.game_data["player_hp_now"] = 180
	VarsGlobal.game_data["player_hp_max"] = 180
	VarsGlobal.game_data["player_mp_now"] = 120
	VarsGlobal.game_data["player_mp_max"] = 120
	
	
	VarsGlobal.game_data["exp"] = 0

	
	VarsGlobal.game_data["player_equip_items"].append(GVar.EQUIPMENT.SACUANJOCHE)
	VarsGlobal.game_data["player_equip_items"].append(GVar.EQUIPMENT.BATTLE_CLOTHES)
	VarsGlobal.game_data["player_equip_items"].append(GVar.EQUIPMENT.BATTLE_BOOTS)
	

	ElementalCircuits.obtain(
		GVar.EC_MODE.ACTION, GVar.EC_ACTION.PYRO_PROIECTUM
	)
	
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.SLIDE
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.CHAINED_ATTACK
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.DOUBLE_JUMP
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.AIR_KICK
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.WHIP_SPIN
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.WHIP_CRUSH
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.BLOOD_CONTROL
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.BLADE_WHIP
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.DODGE
	)

	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.AERIAL_DASH
	)

	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.MULTIPLE_EQUIPMENT
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.WALL_SLIDE
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.SWING
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.SWING
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.AMPHIBIOUS_BREATHING
	)

	ElementalCircuits.obtain(
		GVar.EC_MODE.ACTION, GVar.EC_ACTION.CONGELATIO
	)
	
	ElementalCircuits.obtain(
		GVar.EC_MODE.ACTION, GVar.EC_ACTION.FERRUM_ASCIA
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.WHIP_CRUSH
	)
	
	
	
	
	
	VarsGlobal.game_data["player_ec_alloy"][GVar.ALLOYS.C] = 1
	
	VarsGlobal.game_data["player_ec_alloy"][GVar.ALLOYS.MG] = 1
	
	VarsGlobal.game_data["player_ec_alloy"][GVar.ALLOYS.N] = 1
	VarsGlobal.game_data["player_ec_alloy"][GVar.ALLOYS.O] = 1
	VarsGlobal.game_data["player_ec_alloy"][GVar.ALLOYS.XE] = 1
	VarsGlobal.game_data["player_ec_alloy"][GVar.ALLOYS.H] = 1
	
	

	ElementalCircuits.obtain(
		GVar.EC_MODE.ACTION, GVar.EC_ACTION.ELECTRO_SPHAERA
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ACTION, GVar.EC_ACTION.PYRO_PROIECTUM
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ACTION, GVar.EC_ACTION.FRIGUS_PILAR
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ACTION, GVar.EC_ACTION.DISSOLVIO_RADIUM
	)

	ElementalCircuits.obtain(
		GVar.EC_MODE.ACTION, GVar.EC_ACTION.LUX_PILAR
	)
	ElementalCircuits.obtain(
		GVar.EC_MODE.ACTION, GVar.EC_ACTION.AQUA_FLUERE
	)

	

func _ready() -> void :
	if Features.has("debug") == true:
		debug_data()
