extends Node

func _ready() -> void :
	if VarsGlobal.has_flag("eldralis_spikeball_destroyed1") == true:
		VarsGlobal.GameScenario.get_node("AnotherEntry").queue_free()


func _on_HurtboxEnemySimple_defeated() -> void :
	
	Audio.play_sfx("door_opening")
	
	VarsGlobal.add_flag("eldralis_spikeball_destroyed1")
	
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.GameInterface.can_pause = false
	
	VarsGlobal.Player.stop_move()
	
	VarsGlobal.GameScenario.get_node(
		"AnotherEntry/SpikeballActivator/Spikeball"
	).set_deferred("mode", RigidBody2D.MODE_RIGID)
	
	var TwPos: = get_tree().create_tween()
	
	TwPos.tween_property(
		VarsGlobal.GameScenario.get_node(
			"AnotherEntry/SpikeballActivator/Chain"
		), "position", Vector2( - 2201, - 338), 2
	)
	
	VarsGlobal.GameScenario.CameraNode.move_to(
		VarsGlobal.GameScenario.get_node(
			"AnotherEntry/Position2DEntrance"
		).global_position, 8
	)
	
	yield(get_tree().create_timer(8), "timeout")
	
	Audio.play_sfx("door_opening")
	
	VarsGlobal.GameScenario.get_node(
		"AnotherEntry/AnimationPlayer"
	).play("open")
	
	yield(
		VarsGlobal.GameScenario.get_node(
			"AnotherEntry/AnimationPlayer"
		), "animation_finished"
	)
	
	VarsGlobal.GameScenario.CameraNode.return_to_player(5)

	yield(
		VarsGlobal.GameScenario.CameraNode, "tweened_to_player"
	)

	VarsGlobal.Player.set_enabled_input(true)
	VarsGlobal.GameInterface.can_pause = true
