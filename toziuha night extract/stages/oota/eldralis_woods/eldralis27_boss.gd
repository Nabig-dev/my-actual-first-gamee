extends Node




func _ready() -> void :
	
	
	if VarsGlobal.GameScenario.get_node("Plasmoid").BossNode.was_defeated():
		VarsGlobal.GameScenario.get_node("NewPlatform/AnimationPlayer").play("top")
		VarsGlobal.GameScenario.get_node("BossCinematic").queue_free()
	
	else:
		
		VarsGlobal.GameScenario.connect(
			"boss_defeated", 
			self, 
			"_on_boss_defeated"
		)
		yield(get_tree().create_timer(0.1), "timeout")
		
		
		if (
			VarsGlobal.Player.global_position.x
			> VarsGlobal.GameScenario.get_node("Plasmoid").global_position.x
		):
			VarsGlobal.GameScenario.get_node("Plasmoid").global_position.x -= 300
		




func _on_boss_defeated() -> void :
	VarsGlobal.GameScenario.get_node("NewPlatform/AnimationPlayer").play("to_top")

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :

	Audio.stop_music()

	VarsGlobal.Player.velocity.x = 0
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.GameInterface.can_pause = false
	
	
	VarsGlobal.GameScenario.get_node("DoorBoss").door_locked = true
	
	
	
	
	if (
		VarsGlobal.Player.global_position.x
		> VarsGlobal.GameScenario.get_node("Plasmoid").global_position.x
	):
		
		VarsGlobal.Player.move(Vector2.LEFT)
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.Player.stop_move()
	else:
		
		VarsGlobal.Player.move(Vector2.RIGHT)
		yield(get_tree().create_timer(0.1), "timeout")
		VarsGlobal.Player.stop_move()
	
	yield(get_tree().create_timer(1), "timeout")
	
	VarsGlobal.GameScenario.CameraNode.move_to(
		VarsGlobal.GameScenario.get_node("Plasmoid").global_position, 
		3
	)
	yield(VarsGlobal.GameScenario.CameraNode, "tweened_to_position")
	
	VarsGlobal.GameScenario.get_node("Plasmoid").start_battle()
	
	yield(get_tree().create_timer(3), "timeout")
	VarsGlobal.GameScenario.CameraNode.return_to_player(1)
