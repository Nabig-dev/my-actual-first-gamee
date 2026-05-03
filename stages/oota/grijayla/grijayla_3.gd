extends Node







func _ready() -> void :
	
	
	
	if VarsGlobal.has_flag("grijayla3_box_rope_cuted") == true:
		VarsGlobal.GameScenario.get_node("Node2DTutoBox/AnimatedSpriteShine").visible = false
		VarsGlobal.GameScenario.get_node("Node2DTutoBox/Box/BoxSet").visible = false
		VarsGlobal.GameScenario.get_node("Node2DTutoBox/Box").global_position = VarsGlobal.GameScenario.get_node("Node2DTutoBox/Position2DBoxOnFloor").global_position
		VarsGlobal.GameScenario.get_node("Node2DTutoBox/HurtboxRope").queue_free()

	
	if VarsGlobal.has_flag("tuto_box_and_axe_showed") == false:
		Savedata.update_flag_game("tuto_box_and_axe_showed")
		VarsGlobal.GameScenario.CameraNode.connect("tweened_to_position", self, "_on_camera_tweened_to_position")
		VarsGlobal.GameScenario.CameraNode.connect("tweened_to_player", self, "_on_camera_tweened_to_player")
		VarsGlobal.GameInterface.connect("dialog_ended", self, "_on_tuto_ended")
		
		VarsGlobal.GameInterface.can_pause = false
		yield(get_tree().create_timer(1), "timeout")
		
		VarsGlobal.GameScenario.CameraNode.move_to(
			VarsGlobal.GameScenario.get_node("Node2DTutoBox/Position2DSeeBox").global_position, 3
		)
	
	else:
		yield(get_tree().create_timer(0.5), "timeout")
		VarsGlobal.Player.set_enabled_input(true)
	
	
	
	if VarsGlobal.GameScenario.get_node("Area2DCastIsOnTop").is_colliding() == true:
		VarsGlobal.GameScenario.get_node("AhuizoteMolotov").global_position = VarsGlobal.GameScenario.get_node("Position2DAhuizoteTop2").global_position
	else:
		VarsGlobal.GameScenario.get_node("AhuizoteMolotov").global_position = VarsGlobal.GameScenario.get_node("Position2DAhuizoteTop1").global_position


func _on_camera_tweened_to_position() -> void :
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.GameInterface.show_tuto_screen(1, false)


func _on_tuto_ended(_tuto_name: String) -> void :
	VarsGlobal.GameScenario.CameraNode.return_to_player(2)


func _on_camera_tweened_to_player() -> void :
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)



func _on_Box_body_shape_entered(_body_rid: RID, _body: Node, _body_shape_index: int, _local_shape_index: int) -> void :
	VarsGlobal.GameScenario.get_node("Node2DTutoBox/Box/BoxSet").visible = false
	VarsGlobal.GameScenario.get_node("Node2DTutoBox/AnimatedSpriteShine").visible = false
	
	Audio.play_sfx("explosion_light2")
	VarsGlobal.GameScenario.CameraNode.start_shake(
		0.4, false, true
	)


func _on_HurtboxRope_defeated() -> void :
	VarsGlobal.add_flag("grijayla3_box_rope_cuted")
	VarsGlobal.GameScenario.get_node("Node2DTutoBox/Box").set_deferred("mode", RigidBody2D.MODE_CHARACTER)
	VarsGlobal.GameScenario.get_node("Node2DTutoBox/Box").contact_monitor = true
