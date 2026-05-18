extends Node

var witiko_damage_count: int = 0

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")

	if VarsGlobal.GameScenario.get_node_or_null("the_stalker") != null:
		VarsGlobal.GameScenario.get_node("the_stalker").gravity = 0
		VarsGlobal.GameScenario.get_node("the_stalker").velocity = Vector2.ZERO

		VarsGlobal.GameScenario.get_node("the_stalker").patterns.erase("laser")
		VarsGlobal.GameScenario.get_node("the_stalker").patterns.erase("fireball")
	
	if VarsGlobal.has_flag("witiko_grijayla_cinematic") == false:
		
		Audio.stop_music()
		
		
		VarsGlobal.GameScenario.get_node("VignettePlayer").vignette_extra_scale = 0.09
		
		VarsGlobal.GameScenario.CameraNode.connect("tweened_to_position", self, "_on_camera_tweened_to_position")
		
		VarsGlobal.add_flag("witiko_grijayla_cinematic")
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)
		
		Audio.play_sfx("monster_chew_meat")
		VarsGlobal.GameScenario.get_node("BG/Parallax/BossWitiko/AnimWitikoPlay").play("the_stalker")
		
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.Player.move(Vector2.RIGHT)
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.Player.stop_move()

		VarsGlobal.GameScenario.CameraNode.move_to(
			VarsGlobal.GameScenario.get_node("Position2DWitikoCameraFocus").global_position, 2.5
		)
	
	else:
		destroy_torchs()

func destroy_torchs() -> void :
	for torch in VarsGlobal.GameScenario.get_node("Torchs").get_children():
		torch.get_node("Destructible/AnimationPlayer").play("destroyed")
		torch.get_node("Destructible/HurtboxDestruct").queue_free()

func _on_camera_tweened_to_position() -> void :
	
	
	
	return
	

func _on_Witiko_damaged() -> void :
	pass

func _on_AnimWitikoPlay_animation_finished(_anim_name: String) -> void :
	
	yield(get_tree().create_timer(1), "timeout")
	
	
	VarsGlobal.GameScenario.get_node("the_stalker").get_node("Sprite").frame = 5
	VarsGlobal.GameScenario.get_node("the_stalker").gravity = 1200
	VarsGlobal.GameScenario.get_node("the_stalker").get_node("GhostTrail").start_trail()
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.GameScenario.get_node("the_stalker").gravity = 250

	VarsGlobal.GameScenario.start_boss_battle()
	
	
	
	
	get_tree().create_tween().tween_property(
		VarsGlobal.GameScenario.get_node("VignettePlayer"), "vignette_extra_scale", 0.0, 8
	)
	
	
	get_tree().create_tween().tween_property(
		VarsGlobal.GameScenario.CameraNode, "zoom", Vector2(0.8, 0.8), 1.5
	)
	
	yield(get_tree().create_timer(2.0), "timeout")
	destroy_torchs()
	yield(get_tree().create_timer(3.0), "timeout")
	
	
	VarsGlobal.GameScenario.CameraNode.return_to_player(1.0)
	
	get_tree().create_tween().tween_property(
		VarsGlobal.GameScenario.CameraNode, "zoom", Vector2(1, 1), 0.1
	)
	yield(get_tree().create_timer(1.5), "timeout")
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)

	VarsGlobal.GameScenario.get_node("the_stalker").get_node("GhostTrail").stop_trail()
