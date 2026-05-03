extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.has_flag("eva_1st_dialog") == false:
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)
		
		VarsGlobal.GameScenario.CameraNode.connect("tweened_to_position", self, "_on_camera_tweened_to_position")
		VarsGlobal.GameScenario.CameraNode.connect("tweened_to_player", self, "_on_camera_tweened_to_player")
		VarsGlobal.GameInterface.connect("dialog_ended", self, "_on_dialog_ended")
	
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.Player.jump(1.0)
		VarsGlobal.Player.move(Vector2.RIGHT)
		yield(get_tree().create_timer(0.8), "timeout")
		VarsGlobal.Player.stop_move()
		
		VarsGlobal.GameScenario.CameraNode.move_to(
			VarsGlobal.GameScenario.get_node("EvaAndAhui/Position2D").global_position, 3
		)

	else:
		_on_camera_tweened_to_player()


func _on_camera_tweened_to_position() -> void :
	VarsGlobal.GameScenario.get_node("EvaAndAhui/Ahui1").flip_h = true
	VarsGlobal.GameScenario.get_node("EvaAndAhui/Ahui2").flip_h = true
	yield(get_tree().create_timer(0.7), "timeout")
	VarsGlobal.GameInterface.start_dialog("grijayla-eva-1st-dialog")

func _on_dialog_ended(_dialog: String) -> void :
	Audio.play_voice("eva_laugh")
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.GameScenario.CameraNode.return_to_player(2)
	VarsGlobal.add_flag("eva_1st_dialog")

func _on_camera_tweened_to_player() -> void :
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	
	VarsGlobal.GameScenario.get_node("AhuizoteWithKnife").global_position = VarsGlobal.GameScenario.get_node("EvaAndAhui/Ahui1").global_position
	VarsGlobal.GameScenario.get_node("AhuizoteWithKnife2").global_position = VarsGlobal.GameScenario.get_node("EvaAndAhui/Ahui2").global_position
	
	VarsGlobal.GameScenario.get_node("SpawnerZombies").active = true
	VarsGlobal.GameScenario.get_node("EvaAndAhui").queue_free()
