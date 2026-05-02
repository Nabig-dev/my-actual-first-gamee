extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	if VarsGlobal.has_flag("ahalcana_meeted") == false:
		
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.Player.stop_move()
		VarsGlobal.GameInterface.can_pause = false
		
		VarsGlobal.GameScenario.get_node("NPCAhalcana").get_node("AnimationPlayer").play("hidden")
		
		VarsGlobal.GameScenario.get_node("Balor").queue_free()
		VarsGlobal.GameScenario.get_node("Azche").queue_free()
		VarsGlobal.GameScenario.get_node("BoarWarrior").queue_free()
		
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.Player.move(Vector2.LEFT)
		yield(get_tree().create_timer(2.3), "timeout")
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(1), "timeout")
		
		Audio.stop_music()
		
		VarsGlobal.GameScenario.CameraNode.move_to(
			VarsGlobal.GameScenario.get_node("NPCAhalcana").global_position, 3
		)
		yield(VarsGlobal.GameScenario.CameraNode, "tweened_to_position")
		
		yield(get_tree().create_timer(1), "timeout")
		
		
		VarsGlobal.GameInterface.start_dialog("meet-alcahana-pre")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.GameInterface.can_pause = false
		
		Audio.play_music("before_toziuha")
		yield(get_tree().create_timer(1), "timeout")
		
		Audio.play_sfx("crystal_soul_generating2")
		VarsGlobal.GameScenario.get_node("NPCAhalcana/AnimationPlayer").play("show")
		yield(VarsGlobal.GameScenario.get_node("NPCAhalcana/AnimationPlayer"), "animation_finished")
		
		VarsGlobal.GameScenario.get_node("NPCAhalcana/AnimationPlayer").play("idle")
		yield(get_tree().create_timer(5), "timeout")
		VarsGlobal.GameInterface.start_dialog("ahalcana-meet")
		get_tree().paused = false
		yield(VarsGlobal.GameInterface, "dialog_ended")
		
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.GameInterface.can_pause = false
		
		yield(get_tree().create_timer(1), "timeout")
		Audio.play_music("beginning_of_darkness")
		
		var Tw: = create_tween()
		
		Tw.tween_property(
			VarsGlobal.GameScenario.get_node("NPCAhalcana"), 
			"scale", Vector2(0.1, 0.1), 2.3
		)
		
		Tw.parallel().tween_property(
			VarsGlobal.GameScenario.get_node("NPCAhalcana"), 
			"global_position:y", 
			VarsGlobal.GameScenario.get_node("NPCAhalcana").global_position.y - 400, 1.5
		).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		
		Tw.parallel().tween_property(
			VarsGlobal.GameScenario.get_node("NPCAhalcana"), 
			"modulate", 
			Color("00ffffff"), 3
		)
		
		
		yield(Tw, "finished")
		VarsGlobal.GameScenario.get_node("NPCAhalcana").queue_free()
		
		
		VarsGlobal.GameScenario.CameraNode.return_to_player(0.5)
		yield(VarsGlobal.GameScenario.CameraNode, "tweened_to_player")
		
		VarsGlobal.add_flag("ahalcana_meeted")
		VarsGlobal.Player.set_enabled_input(true)
		VarsGlobal.GameInterface.can_pause = true

	else:
		VarsGlobal.GameScenario.get_node("NPCAhalcana").queue_free()
