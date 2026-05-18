extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.current_building_door != "":
		VarsGlobal.Player.global_position = VarsGlobal.GameScenario.get_node(
			VarsGlobal.current_building_door
		).global_position
		VarsGlobal.current_building_door = ""

	if VarsGlobal.has_flag("amerithiaback_atreu_event") == true:
		VarsGlobal.GameScenario.get_node("NPCGabriel").queue_free()

func go_to_restaurant() -> void :
	VarsGlobal.current_building_door = ""
	VarsGlobal.game_data["player_facing"] = 1
	VarsGlobal.Player.velocity.x = 0
	
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	Audio.play_sfx("door_simple_open")

	SceneChanger.change_scene("res://stages/oota/the_core/restaurant.tscn")

func _on_Area2D_area_entered(_area: Area2D) -> void :
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	VarsGlobal.GameInterface.can_pause = false
	yield(get_tree().create_timer(1.5), "timeout")
	VarsGlobal.GameInterface.start_dialog("atreu-amerithiaback")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	VarsGlobal.add_flag("amerithiaback_atreu_event")
	VarsGlobal.Player.set_enabled_input(true)
	VarsGlobal.GameInterface.can_pause = true
