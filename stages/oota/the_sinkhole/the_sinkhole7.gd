extends Node

var is_talking: bool

func refresh_dialogic_vars() -> void :
	Dialogic.set_variable(
		"eztilia_1st_talk_kalev", 
		int(VarsGlobal.has_flag("eztilia_1st_talk_kalev"))
	)

func _on_RoomChangerUp_player_positioned() -> void :
	yield(get_tree().create_timer(0.6), "timeout")
	VarsGlobal.GameScenario.get_node(
		"TransportPlatform"
	).PathFollowNode.unit_offset = 1
	VarsGlobal.GameScenario.get_node(
		"TransportPlatform"
	).dir = - 1

func _on_RoomChanger3_player_positioned() -> void :
	_on_RoomChangerUp_player_positioned()

func _on_InteractableArea2DIndicator_interact_requested() -> void :
	if is_talking == true:
		return
	
	is_talking = true
	
	refresh_dialogic_vars()
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()

	yield(get_tree().create_timer(0.8), "timeout")

	
	VarsGlobal.GameInterface.start_dialog("kalev-talk1")
	
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	
	if VarsGlobal.has_flag("eztilia_1st_talk_kalev") == false:
		VarsGlobal.add_flag("eztilia_1st_talk_kalev")

	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	is_talking = false

