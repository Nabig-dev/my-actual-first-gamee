extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.has_flag("grijayla_44_atreu_event") == true:
		VarsGlobal.GameScenario.get_node("AtreuCinematic").queue_free()

func _on_Area2D_area_entered(_area: Area2D) -> void :
	
	VarsGlobal.add_flag("grijayla_44_atreu_event")
	
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	VarsGlobal.GameInterface.can_pause = false
	
	VarsGlobal.GameScenario.CameraNode.move_to(
		VarsGlobal.GameScenario.get_node("AtreuCinematic/Position2DCamera").global_position, 2
	)
	
	yield(VarsGlobal.GameScenario.CameraNode, "tweened_to_position")
	
	VarsGlobal.GameScenario.get_node("AtreuCinematic/AnimationPlayer").play("shoot")

	yield(VarsGlobal.GameScenario.get_node("AtreuCinematic/AnimationPlayer"), "animation_finished")
	
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.GameScenario.CameraNode.return_to_player(1)
	VarsGlobal.GameScenario.get_node("AtreuCinematic/SpriteAtreu").scale.x = - 1
	yield(VarsGlobal.GameScenario.CameraNode, "tweened_to_player")
	
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.GameInterface.start_dialog("atreu-defeatingdemon")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	VarsGlobal.Player.set_enabled_input(true)
	VarsGlobal.GameInterface.can_pause = true
