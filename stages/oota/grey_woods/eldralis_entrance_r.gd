extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	if VarsGlobal.current_building_door != "":
		VarsGlobal.Player.global_position = VarsGlobal.GameScenario.get_node(
			VarsGlobal.current_building_door
		).global_position
		VarsGlobal.current_building_door = ""

func _on_XandriaHouseDoor_interact_requested() -> void :
	VarsGlobal.current_room_changer = ""
	VarsGlobal.current_building_door = ""
	VarsGlobal.game_data.current_room_changer = ""
	VarsGlobal.game_data.current_building_door = ""
	VarsGlobal.game_data["player_facing"] = 1
	VarsGlobal.Player.velocity.x = 0
	
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	Audio.play_sfx("door_simple_open")
	SceneChanger.change_scene("res://stages/oota/grey_woods/xandria_house.tscn")
