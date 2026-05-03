extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.current_building_door != "":
		VarsGlobal.Player.global_position = VarsGlobal.GameScenario.get_node(
			VarsGlobal.current_building_door
		).global_position
		VarsGlobal.current_building_door = ""
	
	
	if VarsGlobal.has_flag("margaret_pos_rescue_talk1") == true:
		VarsGlobal.GameScenario.get_node("DoorInterior2").queue_free()


func _on_InteractableArea2DIndicator_interact_requested() -> void :
	VarsGlobal.current_building_door = ""
	VarsGlobal.game_data["player_facing"] = 1
	VarsGlobal.Player.velocity.x = 0
	var go_to_scene: String = "res://stages/oota/amerithia/alessa_office.tscn"
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	Audio.play_sfx("door_simple_open")
	SceneChanger.change_scene(go_to_scene)
