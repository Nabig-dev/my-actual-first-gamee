tool 




extends Node


var ElectroSphaera = preload("res://src/game_objects/elemental_circuits/electro_sphaera.tscn")

var PyroBall = preload("res://src/game_objects/elemental_circuits/pyro_ball.tscn")
var FrigusPilar = preload("res://src/game_objects/elemental_circuits/frigus_pilar.tscn")
var LuxTenebris = preload("res://src/game_objects/elemental_circuits/lux_tenebris.tscn")
var RubrusDraco = preload("res://src/game_objects/elemental_circuits/rubrus_draco.tscn")

var SangriImpalia = preload("res://src/game_objects/elemental_circuits/sangri_impalia.tscn")
var PermetriCaloris = preload("res://src/game_objects/elemental_circuits/permetri_caloris.tscn")

var DissolvioRadium = preload("res://src/game_objects/elemental_circuits/dissolvio_radium.tscn")
var LuxPilar = preload("res://src/game_objects/elemental_circuits/lux_pilar.tscn")
var AquaFluere = preload("res://src/game_objects/elemental_circuits/aqua_fluere.tscn")
var Congelatio = preload("res://src/game_objects/elemental_circuits/congelatio.tscn")


var SubweaponAxe = preload("res://src/game_objects/weapons/player_axe.tscn")
var SubweaponShuriken = preload("res://src/game_objects/weapons/player_shuriken.tscn")

var SubweaponTornado = preload("res://src/game_objects/weapons/player_tornado.tscn")




func load_subweapon(subweapon: int) -> Object:
	var subweapon_instance: Object = null
	
	match subweapon:
		_:
			subweapon_instance = SubweaponAxe.instance()











	
	return subweapon_instance


func get_mode_string(mode: int) -> String:
	return GVar.EC_MODE.keys()[mode + 1]




func get_circuit_string(mode: int, circuit: int, real_name: bool = false) -> String:
	
	var returned_circuit: String
	
	match mode:
		GVar.EC_MODE.ACTION:
			returned_circuit = GVar.EC_ACTION.keys()[circuit + 1]
		GVar.EC_MODE.ABILITY:
			returned_circuit = GVar.EC_ABILITY.keys()[circuit + 1]
		GVar.EC_MODE.SUBWEAPON:
			returned_circuit = GVar.EC_SUBWEAPON.keys()[circuit + 1]
	
	
	if real_name == true:
		returned_circuit = tr(returned_circuit)
		if mode == GVar.EC_MODE.ACTION:
			returned_circuit = returned_circuit.capitalize()
	
	return returned_circuit


func spawn_action_circuit(
	action_circuit: int, glob_position: Vector2
) -> void :
	
	var NodeToSpawn: Object = VarsGlobal.GameScenario
	
	var auto_global_position: bool = true

	var instance_ec: Object = null
	
	match action_circuit:
		
		GVar.EC_ACTION.ELECTRO_SPHAERA:
			var sphaeras: Array = get_tree().get_nodes_in_group(
				"electro_sphaera"
			)
			if sphaeras.size() < 2:
				instance_ec = ElectroSphaera.instance()



		GVar.EC_ACTION.PYRO_PROIECTUM:
			instance_ec = PyroBall.instance()
			instance_ec.dir = VarsGlobal.Player.facing
		GVar.EC_ACTION.FRIGUS_PILAR:
			instance_ec = FrigusPilar.instance()
			instance_ec.dir = VarsGlobal.Player.facing
		GVar.EC_ACTION.RUBRUS_DRACO:
			instance_ec = RubrusDraco.instance()
			instance_ec.dir = VarsGlobal.Player.facing


		GVar.EC_ACTION.SANGRI_IMPALIA:
			instance_ec = SangriImpalia.instance()
			instance_ec.dir = VarsGlobal.Player.facing
			glob_position = VarsGlobal.Player.global_position
		GVar.EC_ACTION.LUX_TENEBRIS:
			var lux_tenebris: Array = get_tree().get_nodes_in_group("lux_tenebris")
			if VarsGlobal.has_flag("lux_tenebris_started", 1) == true:
				if lux_tenebris.size() == 0:
					instance_ec = LuxTenebris.instance()
				for v in get_tree().get_nodes_in_group("lux_tenebris"):
					v.finish_circuit()
			else:
				instance_ec = LuxTenebris.instance()
		GVar.EC_ACTION.PERMETRI_CALORIS:
			instance_ec = PermetriCaloris.instance()
		GVar.EC_ACTION.DISSOLVIO_RADIUM:
			var dissolvios: Array = get_tree().get_nodes_in_group("dissolvio_radium")
			if dissolvios.size() == 0:
				instance_ec = DissolvioRadium.instance()
				NodeToSpawn = VarsGlobal.Player
				auto_global_position = false
				instance_ec.position = Vector2(25 * VarsGlobal.Player.facing, - 35)
				instance_ec.scale.x = VarsGlobal.Player.facing
				if VarsGlobal.Player.anim_current == "throw-crouch":
					instance_ec.position.y += 15
		GVar.EC_ACTION.LUX_PILAR:
			instance_ec = LuxPilar.instance()
		GVar.EC_ACTION.AQUA_FLUERE:
			instance_ec = AquaFluere.instance()
			auto_global_position = false
			NodeToSpawn = VarsGlobal.Player
			instance_ec.position = Vector2(10 * VarsGlobal.Player.facing, - 35)
			instance_ec.scale.x = VarsGlobal.Player.facing
		GVar.EC_ACTION.CONGELATIO:
			instance_ec = Congelatio.instance()
		GVar.EC_ACTION.VOLTUSA:
			var voltusas: Array = get_tree().get_nodes_in_group("voltusas")
			if voltusas.size() < 2:
				instance_ec = SubweaponTornado.instance()
				instance_ec.dir = VarsGlobal.Player.facing
				instance_ec.add_to_group("voltusas")
			












		GVar.EC_ACTION.FERRUM_ASCIA:
			instance_ec = SubweaponAxe.instance()
			instance_ec.dir = VarsGlobal.game_data["player_facing"]
		GVar.EC_ACTION.FERRUM_STELLA:
			instance_ec = SubweaponShuriken.instance()
			instance_ec.dir = VarsGlobal.game_data["player_facing"]
	
	
	var max_spawn: int = 1
	
	if VarsGlobal.game_data["lvl"] >= 30:
		max_spawn = 2
	
	if (
		instance_ec != null
		and get_tree().get_nodes_in_group("circuitspawned").size() >= max_spawn
	):
		instance_ec = null
	
	if instance_ec == null:
		Audio.play_sfx("ui_incorrect")
		return
	
	instance_ec.add_to_group("circuitspawned")
	
	if auto_global_position == true:
		instance_ec.global_position = glob_position
	
	
	apply_mana_cost(
		GVar.EC_MODE.ACTION, action_circuit
	)

	
	VarsGlobal.GameInterface.update_hud_values()
	
	NodeToSpawn.add_child(instance_ec)


func get_attrbs_physical(_circuit: int) -> int:
	return 0

func get_attrbs_elemental(circuit: int) -> Array:
	var ec_dict = CSVDBLoader.get_db("elemental_circuits")
	
	
	var attr_list: Array
	
	for at in ec_dict[get_circuit_string(0, circuit)]["attrb_elemental"].split(","):
		attr_list.append(at.to_upper())

	return attr_list



func get_circuit_action_time(circuit: int) -> int:
	var time_act: int = (
		
		CSVDBLoader.get_db("elemental_circuits")[
			get_circuit_string(GVar.EC_MODE.ACTION, circuit)
		]["time"]
	)
	return time_act


func get_circuit_mp_cost(mode: int, circuit: int) -> int:
	var mp_cost: int = 0
	
	match mode:
		GVar.EC_MODE.ACTION:
			mp_cost = CSVDBLoader.get_db("elemental_circuits")[
				get_circuit_string(GVar.EC_MODE.ACTION, circuit)
			]["mp_cost"]
		GVar.EC_MODE.SUBWEAPON:
			mp_cost = CSVDBLoader.get_db("subweapon_mana_cost")[
				get_circuit_string(GVar.EC_MODE.SUBWEAPON, circuit)
			]["mp_cost"]
	
	return mp_cost


func subweapon_requeriment_is_ok(subweapon_circuit: int) -> bool:
	
	var mana_cost: int = get_circuit_mp_cost(GVar.EC_MODE.SUBWEAPON, subweapon_circuit)
	
	if (
		VarsGlobal.game_data["player_mp_now"] >= mana_cost
		and was_obtained(GVar.EC_MODE.SUBWEAPON, subweapon_circuit)
	):
		
		
		if subweapon_circuit == GVar.EC_SUBWEAPON.LANCEA_ARGENTEA:
			var lancea: Array = get_tree().get_nodes_in_group("lancea_argentea")
			if lancea.size() > 2:
				return false
		
		return true
	
	
	return false


func action_circuit_requeriment_is_ok(action_circuit: int) -> bool:
	
	
	if action_circuit == GVar.EC_ACTION.NONE:
		return false
	
	var mana_cost: int = get_circuit_mp_cost(GVar.EC_MODE.ACTION, action_circuit)
	
	
	var mp_ok: bool = false
	
	var requeriment_ok: bool = false
	
	
	if VarsGlobal.game_data["player_mp_now"] >= mana_cost:
		mp_ok = true
	
	
	match action_circuit:






















		_:
			requeriment_ok = true
	
	
	if mp_ok and requeriment_ok:
		return true
	else:
		return false

func apply_mana_cost(circuit_mode: int, circuit: int) -> void :
	var mana_cost: int = get_circuit_mp_cost(circuit_mode, circuit)
	
	
	var equip_top_ide: int = VarsGlobal.game_data["player_equip_1"][
		VarsGlobal.game_data["player_current_set"]
	]
	
	if equip_top_ide == GVar.EQUIPMENT.MAGIC_EARING:
		
		mana_cost = int(mana_cost / 2)
	
	VarsGlobal.game_data["player_mp_now"] = int(
		FuncsNumbers.decrease_value(mana_cost, VarsGlobal.game_data["player_mp_now"])
	)
	
	if VarsGlobal.GameInterface != null:
		VarsGlobal.GameInterface.update_hud_values()


func was_obtained(circuit_mode: int, circuit: int) -> bool:
	var is_obtained: bool = false
	
	match circuit_mode:
		GVar.EC_MODE.ACTION:
			is_obtained = VarsGlobal.game_data["player_ec_action"].has(circuit)
		GVar.EC_MODE.ABILITY:
			is_obtained = VarsGlobal.game_data["player_ec_ability"].has(circuit)
		GVar.EC_MODE.SUBWEAPON:
			is_obtained = VarsGlobal.game_data["player_ec_subweapon"].has(circuit)
	
	return is_obtained

func obtain(circuit_mode: int, circuit: int, allow_duplicate: bool = true) -> void :
	
	
	if allow_duplicate == false and was_obtained(circuit_mode, circuit) == true:
		return
	
	match circuit_mode:
		GVar.EC_MODE.ACTION:
			VarsGlobal.game_data["player_ec_action"].append(circuit)
		GVar.EC_MODE.ABILITY:
			VarsGlobal.game_data["player_ec_ability"].append(circuit)
			



		GVar.EC_MODE.SUBWEAPON:
			VarsGlobal.game_data["player_ec_subweapon"].append(circuit)
