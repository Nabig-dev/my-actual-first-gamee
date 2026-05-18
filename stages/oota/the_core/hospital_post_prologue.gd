extends Node

func _ready() -> void :
	
	Audio.play_music("rachel_theme")

	$ColorRect.color = Color.black

	var Tw: = get_tree().create_tween()
	
	Tw.tween_property(
		$ColorRect, "color", Color("00000000"), 3
	)
	yield(Tw, "finished")
	
	yield(get_tree().create_timer(1), "timeout")
	
	var new_dialog = Dialogic.start("nabig-recover-post-prologue")
	get_tree().current_scene.add_child(new_dialog)
	
	yield(new_dialog, "timeline_end")
	
	Audio.stop_music()

	Tw = get_tree().create_tween()
	
	Tw.tween_property(
		$ColorRect, "color", Color.black, 3
	)
	yield(Tw, "finished")
	
	
	
	
	
	VarsGlobal.game_data["player_hp_now"] = 50
	VarsGlobal.game_data["player_hp_max"] = 50
	VarsGlobal.game_data["player_mp_now"] = 50
	VarsGlobal.game_data["player_mp_max"] = 50
	
	VarsGlobal.game_data["player_bl_now"] = 0
	VarsGlobal.game_data["player_bl_max"] = 100
	
	if VarsGlobal.game_data["difficulty_base"] == 0:
		VarsGlobal.game_data["player_atk"] = 2
		VarsGlobal.game_data["player_def"] = 4
		VarsGlobal.game_data["player_int"] = 2
	else:
		VarsGlobal.game_data["player_atk"] = 2
		VarsGlobal.game_data["player_def"] = 3
		VarsGlobal.game_data["player_int"] = 1
	
	VarsGlobal.game_data["current_level"] = 1
	VarsGlobal.game_data["exp"] = 0
	
	VarsGlobal.game_data["player_inventory"] = {0: 2}
	
	VarsGlobal.game_data["player_ec_alloy_selected"] = [ - 1, - 1, - 1, - 1]
	VarsGlobal.game_data["player_ec_action_selected"] = [ - 1, - 1, - 1, - 1]
	VarsGlobal.game_data["player_ec_ability_selected"] = [ - 1, - 1, - 1, - 1]
	VarsGlobal.game_data["player_ec_subweapon_selected"] = [ - 1, - 1, - 1, - 1]
	VarsGlobal.game_data["player_ec_alloy"] = {}
	VarsGlobal.game_data["player_ec_action"] = []
	VarsGlobal.game_data["player_ec_ability"] = []
	
	if VarsGlobal.game_data["flags"].has(str(GVar.EQUIPMENT.WITCH_HAT) + "_equipment_obtained") == true:
		VarsGlobal.game_data["flags"].erase(str(GVar.EQUIPMENT.WITCH_HAT) + "_equipment_obtained")
	
	VarsGlobal.game_data["player_equip_items"] = [
		GVar.EQUIPMENT.SACUANJOCHE, 
		GVar.EQUIPMENT.BATTLE_CLOTHES, 
		GVar.EQUIPMENT.BATTLE_BOOTS
	]
	
	for s in [0, 1, 2, 3]:
		VarsGlobal.game_data["player_equip_0"][s] = GVar.EQUIPMENT.SACUANJOCHE
		VarsGlobal.game_data["player_equip_1"][s] = GVar.EQUIPMENT.NONE
		VarsGlobal.game_data["player_equip_2"][s] = GVar.EQUIPMENT.BATTLE_CLOTHES
		VarsGlobal.game_data["player_equip_3"][s] = GVar.EQUIPMENT.BATTLE_BOOTS
	
	ElementalCircuits.obtain(GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.BLOOD_CONTROL)
	
	VarsGlobal.game_data["player_injured"] = false
	VarsGlobal.game_data["player_poisoned"] = false
	VarsGlobal.game_data["player_cursed"] = false
	

	
	VarsGlobal.game_data["player_key_objects"] = []
	
	VarsGlobal.current_room_changer = ""
	VarsGlobal.current_building_door = ""
	VarsGlobal.game_data.current_room_changer = ""
	VarsGlobal.game_data.current_building_door = ""
	
	VarsGlobal.game_data["visited_areas_title"].append("THE_ORDER_HEADQUARTERS")
	VarsGlobal.game_data["visited_areas_title"].append("ALCHEMY_LABORATORY")
	VarsGlobal.game_data["visited_areas_title"].append("SHOP")
	VarsGlobal.game_data["visited_areas_title"].append("LIBRARY")
	VarsGlobal.game_data["visited_areas_title"].append("RESTAURANT")
	VarsGlobal.game_data["visited_areas_title"].append("NABIGSHOUSE")
	
	
	
	VarsGlobal.add_flag("prologue_finished")
	
	SceneChanger.change_scene("res://stages/oota/the_core/amerithia_central.tscn")
