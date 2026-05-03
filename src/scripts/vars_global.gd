extends Node


var GameScenario = null

var GameInterface = null

var Player = null

var selected_slot: int = 0

var selected_stage: String = "oota"


var current_player_char: String = "xandria"


var respawned_savestatue_no_hp_item: bool


var current_building_door: String

var current_room_changer: String

var game_data: Dictionary


var flags: Array

func _ready()->void :
	reset_data()


func has_item_inv(itemid: int)->bool:
	
	if game_data["player_inventory"].keys().has(itemid):
		if game_data["player_inventory"][itemid] > 0:
			return true
	return false

func set_diff_stats(diff: int = 1)->void :
	
	match diff:
		0:
			VarsGlobal.game_data["enemy_damage_multiplier"] = 0.5
			VarsGlobal.game_data["enemy_hp_multiplier"] = 0.7
			VarsGlobal.game_data["price_buy"] = 0.5
		1:
			VarsGlobal.game_data["enemy_damage_multiplier"] = 1.0
			VarsGlobal.game_data["enemy_hp_multiplier"] = 1.0
			VarsGlobal.game_data["price_buy"] = 1.0
		2:
			VarsGlobal.game_data["enemy_damage_multiplier"] = 2.0
			VarsGlobal.game_data["enemy_hp_multiplier"] = 1.5
			VarsGlobal.game_data["price_buy"] = 1.5
	VarsGlobal.game_data["difficulty_base"] = diff



func add_flag(flag: String, type: int = 0)->void :
	if has_flag(flag, type) == false:
		if type == 0:
			game_data["flags"].append(flag)
		else :
			flags.append(flag)
		print_debug("Flag saved: %s" % [flag])

func erase_flag(flag: String, type: int = 0)->void :
	if has_flag(flag, type) == true:
		if type == 0:
			game_data["flags"].erase(flag)
		else :
			flags.erase(flag)


func has_flag(flag: String, type: int = 0)->bool:
	if type == 0:
		return game_data["flags"].has(flag)
	else :
		return flags.has(flag)

func reset_data()->void :
	current_room_changer = ""
	current_building_door = ""
	game_data = {
		"character": "xandria", 
		"player_facing": 1, 
		"lvl": 1, 
		"exp": 0, 
		"player_hp_now": 50, 
		"player_hp_max": 50, 
		"player_mp_now": 50, 
		"player_mp_max": 50, 
		"player_sp_now": 50, 
		"player_sp_max": 50, 
		"player_bl_now": 0, 
		"player_bl_max": 100, 
		"player_potions_max": 2, 
		"player_money": 888850000, 
		"player_atk": 1, 
		"player_int": 1, 
		"player_def": 0, 
		"player_injured": false, 
		"player_poisoned": false, 
		"player_cursed": false, 
		"player_inventory": {0: 2}, 
		"player_key_objects": [], 
		"player_treasures": {}, 
		"player_notes": [], 
		"player_current_set": 0, 
		"player_equip_items": [], 
		"player_equip_0": [ - 1, - 1, - 1, - 1], 
		"player_equip_1": [ - 1, - 1, - 1, - 1], 
		"player_equip_2": [ - 1, - 1, - 1, - 1], 
		"player_equip_3": [ - 1, - 1, - 1, - 1], 
		"player_ec_alloy_selected": [ - 1, - 1, - 1, - 1], 
		"player_ec_action_selected": [ - 1, - 1, - 1, - 1], 
		"player_ec_ability_selected": [ - 1, - 1, - 1, - 1], 
		"player_ec_subweapon_selected": [ - 1, - 1, - 1, - 1], 
		"player_ec_alloy": {}, 
		"player_ec_action": [], 
		"player_ec_ability": [], 
		"player_ec_subweapon": [], 
		"save_name": "XANDRIA", 
		"current_room": "", 
		"current_room_path": "", 
		"current_area_title": "", 
		"visited_areas_title": [], 
		"visited_rooms": [], 
		"visible_tiles": [], 
		"visited_tiles": [], 
		"map_markers": {}, 
		"millis_elapsed": 0.0, 
		"levelup_items": [], 
		"last_save_room_used": "", 
		"flags": [], 
		"total_deaths": 0, 
		"boss_total_deaths": {}, 
		"enemy_hp_multiplier": 1.0, 
		"enemy_damage_multiplier": 1.0, 
		"price_buy": 1.0, 
		"difficulty_base": 1, 
		"cycle_game": 1, 
		"enemies_deaths": {}
	}



func add_exp(expval: int)->bool:
	
	var max_lvl: int = 20
	
	if get_version_status() == "stable":
		max_lvl = 255
	
	
	if expval <= 0 or game_data["lvl"] >= max_lvl:
		return false
	
	
	var lvlup: bool = false
	
	var exp_total: int = game_data["exp"]
	
	var exp_acum: int = exp_total + expval
	
	var exp_next: int = get_exp_required()
	
	var lvl: int = game_data["lvl"]
	
	
	while exp_acum >= exp_next:
		
		lvlup = true
		
		if lvl < max_lvl:
			
			game_data["player_hp_max"] += 10
			game_data["player_mp_max"] += 5
			game_data["player_bl_max"] += 10
			game_data["player_sp_max"] += 2
			game_data["player_atk"] += 1
			game_data["player_def"] += 1
			game_data["player_int"] += 1
			
			lvl += 1
		
		exp_acum -= exp_next
		
		exp_next = get_exp_required()
	
	
	game_data["exp"] = exp_total + expval
	game_data["lvl"] = lvl
	
	return lvlup


func get_version_status()->String:
	var ver_st: String = "stable"
	if Features.has("early"):
		ver_st = "early_access"
	elif Features.has("demo"):
		ver_st = "demo"
	if Features.has("beta"):
		ver_st = "beta"
	return ver_st



func get_exp_next()->int:
	
	var next_exp: int = get_exp_required()
	var now_exp: int = game_data["exp"]
	return next_exp - now_exp


func get_exp_required()->int:
	var lvlnow: int = game_data["lvl"] + 1
	
	
	
	
	var exp_required: int = 2 * lvlnow + 5 * pow(lvlnow, 2) + 3 * pow(lvlnow, 3)
	return exp_required




func get_stat(stat: String, get_val: int = 2, ret_zero_neg: bool = true)->int:
	var equip_sheet = CSVDBLoader.get_db("equipment_objects")
	var val_to_return: int = 0
	
	var stat_equip: int = 0
	
	var stat_base: int = game_data["player_" + stat]
	
	
	if get_val == 0:
		return stat_base
	
	
	for eq in ["0", "1", "2", "3"]:
		
		var equip_ide: int = game_data["player_equip_" + eq][
			game_data["player_current_set"]
		]
		
		if equip_ide != - 1:
			
			var equip_data: Dictionary = equip_sheet[GVar.EQUIPMENT.keys()[equip_ide + 1]]
			
			stat_equip += equip_data[stat]
	
	
	if get_val == 2:
		val_to_return = stat_base + stat_equip
	
	else :
		val_to_return = stat_equip
	
	
	if (
		stat == "atk"
		 and get_tree().get_nodes_in_group("scutum_alligatios").size() > 0
	):
		val_to_return -= int(val_to_return * 30.0 / 100.0)
	
	
	if val_to_return < 0 and ret_zero_neg == true:
		val_to_return = 0
	
	return val_to_return


func get_map_percentage(total_visited_tiles: int = 0)->float:
	var Dir = Directory.new()
	var percentage: float = 0.0
	var total_tiles: int = 0

	var map_scene_path: String = "res://stages/%s/map.tscn" % [
		VarsGlobal.selected_stage
	]
	
	if Dir.file_exists(map_scene_path) == false:
		return 0.0
		
	
	var MapScene = load(map_scene_path).instance()
	for t in MapScene.get_children():
		if t is TileMap and t.type == t.TYPES.BG_COLOR:
			total_tiles = t.get_used_cells().size()
	
	percentage = FuncsNumbers.get_percentage(total_visited_tiles, total_tiles)
	
	return percentage


func get_medallion_order()->String:
	var str_result: String = "Si.H.S.O.N.Fe.Cl"
	
	for f in game_data["flags"]:
		if f.begins_with("medallion_order_"):
			str_result = f.trim_prefix("medallion_order_")
			return str_result

	return str_result


func get_dict_parsed_fixed(dict: Dictionary)->Dictionary:
	for k in dict:
		
		if str(dict[k]).is_valid_integer():
			dict[k] = int(dict[k])
		
		elif str(dict[k]).is_valid_float():
			dict[k] = float(dict[k])
		
		elif dict[k] is Array:
			dict[k] = _get_fixed_array(dict[k])
		
		elif dict[k] is Dictionary:
			dict[k] = _get_fixed_dictionary(dict[k])
	return dict


func _get_fixed_array(arr: Array)->Array:
	var new_arr: Array = []
	for it in arr:
		if str(it).is_valid_integer():
			it = int(it)
		elif str(it).is_valid_float():
			it = float(it)
		elif str(it).begins_with("["):
			it = str2var(str(it))
		elif str(it) in ["true", "True"]:
			it = true
		elif str(it) in ["false", "False"]:
			it = false
		new_arr.append(it)
	return new_arr


func _get_fixed_dictionary(dict: Dictionary)->Dictionary:
	var new_dict: Dictionary = {}
	for k in dict:
		
		var key
		if str(k).is_valid_integer():
			key = int(k)
		else :
			key = str(k)
		
		var value
		if str(dict[k]).is_valid_integer():
			value = int(dict[k])
		elif str(dict[k]).is_valid_float():
			value = float(dict[k])
		elif str(dict[k]).begins_with("["):
			value = str2var(str(dict[k]))
		elif str(dict[k]) in ["true", "True"]:
			value = true
		elif str(dict[k]) in ["false", "False"]:
			value = false
		else :
			value = str(dict[k])
		
		new_dict[key] = value
	return new_dict
