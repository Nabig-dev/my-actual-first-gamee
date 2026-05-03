extends Node

var SkeletonEnemy = preload("res://src/game_objects/enemies/skeleton.tscn")

func _ready() -> void :
	
	
	yield(get_tree().create_timer(0.3), "timeout")
	if VarsGlobal.current_building_door != "":
		VarsGlobal.Player.global_position = VarsGlobal.GameScenario.get_node(
			VarsGlobal.current_building_door
		).global_position
		VarsGlobal.current_building_door = ""

	if VarsGlobal.has_flag("move_jump_tuto_finished") == false:
		Audio.play_music("ambient_forest_wind")
	
	
	if VarsGlobal.has_flag("eva_1st_dialog") == true:
		var enemy: Object
		enemy = SkeletonEnemy.instance()
		enemy.global_position = VarsGlobal.GameScenario.get_node("PositionEnemies").global_position
		VarsGlobal.GameScenario.add_child(enemy)
	
	
	
	if VarsGlobal.has_flag("1st_dialog_grijayla_prologue") == false:
		VarsGlobal.add_flag("1st_dialog_grijayla_prologue")
		VarsGlobal.game_data["current_area_title"] = "GRIJAYLA_TOWN"
		_stats_equip_asigment()
		yield(get_tree().create_timer(0.2), "timeout")
		
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.GameInterface.can_pause = false
		
		VarsGlobal.GameScenario.get_node("NPCGabriel").face_to( - 1)
		VarsGlobal.GameScenario.get_node("NPCGabriel").play("crouch")
		
		yield(get_tree().create_timer(1.3), "timeout")
		
		VarsGlobal.Player.move(Vector2.RIGHT)
		yield(get_tree().create_timer(1.5), "timeout")
		VarsGlobal.Player.stop_move()
		
		VarsGlobal.GameScenario.CameraNode.move_to(
			VarsGlobal.GameScenario.get_node("Zombie0").global_position, 
			3
		)
		yield(VarsGlobal.GameScenario.CameraNode, "tweened_to_position")
		Audio.play_sfx("enemy_zombie_roar")
		Audio.play_sfx("ui_player_reborn2")
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.GameScenario.CameraNode.return_to_player()
		yield(VarsGlobal.GameScenario.CameraNode, "tweened_to_player")
		VarsGlobal.Player.move(Vector2.RIGHT)
		yield(get_tree().create_timer(1.8), "timeout")
		VarsGlobal.Player.stop_move()
		VarsGlobal.Player.whip_attack()
		yield(get_tree().create_timer(2), "timeout")
		VarsGlobal.Player.move(Vector2.LEFT)
		yield(get_tree().create_timer(0.1), "timeout")
		VarsGlobal.Player.stop_move()
		VarsGlobal.GameScenario.get_node("NPCGabriel").face_to(1)
		VarsGlobal.GameScenario.get_node("NPCGabriel").play("idle")
		yield(get_tree().create_timer(1), "timeout")
	
		VarsGlobal.GameInterface.start_dialog("grijayla-entrance")
		VarsGlobal.GameInterface.connect("dialog_ended", self, "_on_dialog_end")
	
	
	else:
		VarsGlobal.game_data["current_area_title"] = "GRIJAYLA_TOWN"
		
		yield(get_tree().create_timer(0.1), "timeout")
		VarsGlobal.GameScenario.get_node("NPCGabriel").queue_free()
		VarsGlobal.GameScenario.get_node("Horse").queue_free()
		
		if VarsGlobal.has_flag("prologue_finished") == true:
			
			yield(get_tree().create_timer(0.3), "timeout")
			var area_title_translated: String = tr("GRIJAYLA_TOWN")
			
			if area_title_translated == "GRIJAYLA_TOWN":
				area_title_translated = area_title_translated.capitalize()
			VarsGlobal.GameInterface.get_node("%AreaTitle").play(area_title_translated)


func _stats_equip_asigment() -> void :
	
	VarsGlobal.game_data["player_hp_now"] = 300
	VarsGlobal.game_data["player_hp_max"] = 300
	VarsGlobal.game_data["player_mp_now"] = 200
	VarsGlobal.game_data["player_mp_max"] = 200
	VarsGlobal.game_data["player_atk"] = 20
	VarsGlobal.game_data["player_def"] = 10
	VarsGlobal.game_data["player_int"] = 20
	VarsGlobal.game_data["lvl"] = 15
	VarsGlobal.game_data["exp"] = 4500
	
	VarsGlobal.game_data["player_equip_items"].append(GVar.EQUIPMENT.SACUANJOCHE)
	VarsGlobal.game_data["player_equip_items"].append(GVar.EQUIPMENT.BATTLE_CLOTHES)
	VarsGlobal.game_data["player_equip_items"].append(GVar.EQUIPMENT.BATTLE_BOOTS)
	
	for s in [0, 1, 2, 3]:
		VarsGlobal.game_data["player_equip_0"][s] = GVar.EQUIPMENT.SACUANJOCHE
		VarsGlobal.game_data["player_equip_2"][s] = GVar.EQUIPMENT.BATTLE_CLOTHES
		VarsGlobal.game_data["player_equip_3"][s] = GVar.EQUIPMENT.BATTLE_BOOTS
	
	VarsGlobal.game_data["player_inventory"][GVar.INVENTORY_ITEM.CHIKEN_LEG] = 4
	VarsGlobal.game_data["player_inventory"][GVar.INVENTORY_ITEM.PAN] = 10
	VarsGlobal.game_data["player_inventory"][GVar.INVENTORY_ITEM.POTION_MANA] = 5
	VarsGlobal.game_data["player_inventory"][GVar.INVENTORY_ITEM.POTION_POISON] = 4
	VarsGlobal.game_data["player_inventory"][GVar.INVENTORY_ITEM.FIRST_AID_KIT] = 4
	VarsGlobal.game_data["player_key_objects"].append(GVar.KEYS_OBJECTS.MAGIC_MEDALLION)
	
	
	ElementalCircuits.obtain(GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.BLOOD_CONTROL)
	ElementalCircuits.obtain(GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.CHAINED_ATTACK)
	ElementalCircuits.obtain(GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.BLADE_WHIP)
	ElementalCircuits.obtain(GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.WHIP_CRUSH)
	
	ElementalCircuits.obtain(GVar.EC_MODE.ACTION, GVar.EC_ACTION.FERRUM_ASCIA)
	ElementalCircuits.obtain(GVar.EC_MODE.ACTION, GVar.EC_ACTION.PERMETRI_CALORIS)

	
	VarsGlobal.game_data["player_notes"].append(GVar.NOTES.ADEPTIS)
	VarsGlobal.game_data["player_notes"].append(GVar.NOTES.AHUIZOTE)
	VarsGlobal.game_data["player_notes"].append(GVar.NOTES.TOZIUHA)
	VarsGlobal.game_data["player_notes"].append(GVar.NOTES.DEMON)
	VarsGlobal.game_data["player_notes"].append(GVar.NOTES.ALCHEMIST)

	
	VarsGlobal.game_data["player_ec_action_selected"] = [
		GVar.EC_ACTION.FERRUM_ASCIA, 
		GVar.EC_ACTION.FERRUM_ASCIA, 
		GVar.EC_ACTION.FERRUM_ASCIA, 
		GVar.EC_ACTION.FERRUM_ASCIA
	]
	
	VarsGlobal.game_data["player_bl_now"] = 0
	yield(get_tree(), "idle_frame")
	VarsGlobal.GameInterface.update_hud_values(false)
	VarsGlobal.GameInterface.get_node("%AnimBloodLayout").play("RESET")

func _on_dialog_end(_timeline: String) -> void :
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.GameScenario.CameraNode.current = false
	VarsGlobal.Player.move(Vector2.RIGHT)
	yield(get_tree().create_timer(2), "timeout")
	SceneChanger.change_scene("res://stages/oota/grijayla/grijayla_0.tscn")



func _on_GabrielHouseInteractableArea2DIndicator_interact_requested() -> void :
	VarsGlobal.current_room_changer = ""
	VarsGlobal.current_building_door = ""
	VarsGlobal.game_data.current_room_changer = ""
	VarsGlobal.game_data.current_building_door = ""
	VarsGlobal.game_data["player_facing"] = 1
	VarsGlobal.Player.velocity.x = 0
	var go_to_scene: String
	go_to_scene = "res://stages/oota/eldralis_woods/gabriel_house.tscn"
	
	if go_to_scene.empty() == false:
		
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)
		Audio.play_sfx("door_simple_open")
		SceneChanger.change_scene(go_to_scene)
