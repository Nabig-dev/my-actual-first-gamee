extends Node

func _ready() -> void :
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.has_flag("alessa_aridiah_train_finished") == true:
		VarsGlobal.GameScenario.get_node("TrainStation").active = true
		VarsGlobal.GameScenario.get_node("NPCAlessa").queue_free()
	
	else:
		Audio.play_music("alessa_theme")
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.GameInterface.can_pause = false
		yield(get_tree().create_timer(1.5), "timeout")
		VarsGlobal.Player.move(Vector2.LEFT)
		yield(get_tree().create_timer(0.5), "timeout")
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(1.5), "timeout")
		VarsGlobal.GameInterface.start_dialog("alessa-train-finished")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		VarsGlobal.Player.set_enabled_input(true)
		VarsGlobal.GameInterface.can_pause = true
		VarsGlobal.GameScenario.get_node("TrainStation").active = true
		VarsGlobal.add_flag("alessa_aridiah_train_finished")
		Audio.stop_music()
