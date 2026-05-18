extends Node

func _ready() -> void :
	
	yield(get_tree().create_timer(0.3), "timeout")
	if VarsGlobal.has_flag("xandria_with_antagonist_1stdialog") == false:
		VarsGlobal.GameScenario.get_node("TileMapBuilding2Destroy").position = Vector2.ZERO
		VarsGlobal.GameScenario.get_node("TileMapTerrainStone2Destroy").position = Vector2.ZERO
	
	else:
		VarsGlobal.GameScenario.get_node("Enemies/john").queue_free()
		VarsGlobal.GameScenario.get_node("Enemies/ike").queue_free()
		VarsGlobal.GameScenario.get_node("Enemies/Eve").queue_free()

func explosion_floor() -> void :
	VarsGlobal.GameScenario.get_node("Enemies/ParticlesRocks").emitting = true
	VarsGlobal.Player.jump(1.3)
	VarsGlobal.GameScenario.CameraNode.start_shake(1.0, true, true)
	Audio.play_sfx("explosion_grijayla_cinematic")
	VarsGlobal.GameScenario.get_node("TileMapBuilding2Destroy").queue_free()
	VarsGlobal.GameScenario.get_node("TileMapTerrainStone2Destroy").queue_free()
	
	

func _on_camera_tweened_to_position() -> void :
	
	
	yield(get_tree().create_timer(0.7), "timeout")
	VarsGlobal.GameInterface.start_dialog("the_outpost-main-enemies-dialog-11")
	VarsGlobal.GameInterface.connect("dialog_signal_emitted", self, "_on_DialogSignal")

func _on_DialogSignal(_dialog_name: String, signal_name: String) -> void :
	match signal_name:
		"xandria_pose":
			Audio.stop_music()
			get_tree().paused = false
			yield(get_tree().create_timer(1), "timeout")
			VarsGlobal.Player.change_state("mark", true)

func _on_dialog_ended(dialog: String) -> void :
	if dialog == "the_outpost-main-enemies-dialog-11":
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.change_state("idle", true)
		VarsGlobal.add_flag("xandria_with_antagonist_1stdialog")
		VarsGlobal.GameScenario.get_node("Enemies/AnimationPlayer").play("attack_power")
		
		yield(get_tree().create_timer(1.8), "timeout")
		explosion_floor()

func _on_Area2DCinematic_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("xandria_with_antagonist_1stdialog") == false:
		
		VarsGlobal.GameInterface.can_pause = false
		
		VarsGlobal.GameScenario.CameraNode.connect("tweened_to_position", self, "_on_camera_tweened_to_position")
		VarsGlobal.GameInterface.connect("dialog_ended", self, "_on_dialog_ended", [])
		
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.Player.stop_move()
		if VarsGlobal.Player.is_on_floor() == true:
			VarsGlobal.Player.change_state("idle", true, false)
		VarsGlobal.Player.move(Vector2.RIGHT)

func _on_Area2DCinematic2_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("xandria_with_antagonist_1stdialog") == false:
		VarsGlobal.add_flag("xandria_with_antagonist_1stdialog")
		VarsGlobal.Player.stop_move()
		
		VarsGlobal.GameScenario.CameraNode.move_to(
			VarsGlobal.GameScenario.get_node("Enemies/Position2D").global_position, 3
		)
