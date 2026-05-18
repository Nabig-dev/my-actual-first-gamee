extends Node

func _ready() -> void :
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.current_building_door != "":
		VarsGlobal.Player.global_position = VarsGlobal.GameScenario.get_node(
			VarsGlobal.current_building_door
		).global_position
		VarsGlobal.current_building_door = ""
	
	
	if (
		VarsGlobal.has_flag("margaret_rescued") == true and 
		VarsGlobal.has_flag("margaret_pos_rescue_talk1") == false
	):
		VarsGlobal.GameScenario.get_node("NPCMargaret").global_position = VarsGlobal.GameScenario.get_node("PositionMargaretPosRescue").global_position
		
		VarsGlobal.GameInterface.Node2DMap.add_mark(5, [ - 18, - 4])

func go_to(opt: String) -> void :
	VarsGlobal.current_room_changer = ""
	VarsGlobal.current_building_door = ""
	VarsGlobal.game_data.current_room_changer = ""
	VarsGlobal.game_data.current_building_door = ""
	VarsGlobal.game_data["player_facing"] = 1
	VarsGlobal.Player.velocity.x = 0
	var go_to_scene: String
	match opt:
		"theorder":
			go_to_scene = "res://stages/oota/the_core/the_order_entrance.tscn"
		"lab":
			go_to_scene = "res://stages/oota/the_core/alchemy_lab.tscn"
		"store":
			go_to_scene = "res://stages/oota/the_core/store.tscn"
		"library":
			VarsGlobal.current_room_changer = "dl"
			go_to_scene = "res://stages/oota/the_core/library.tscn"
	
	if go_to_scene.empty() == false:
		
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)
		Audio.play_sfx("door_simple_open")
		SceneChanger.change_scene(go_to_scene)

func _on_AreaDetectPlayer2_area_entered(_area: Area2D) -> void :
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.add_flag("margaret_pos_rescue_talk1")
	VarsGlobal.GameInterface.start_dialog("margaret-talk-pos-rescue1")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
