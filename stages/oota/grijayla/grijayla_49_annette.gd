extends Node

func _ready() -> void :
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.has_flag("defeated_boss_annette1") == false:
		Audio.play_music("before_cavendish")
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.Player.stop_move()
		VarsGlobal.Player.move(Vector2.LEFT)
		yield(get_tree().create_timer(2.5), "timeout")
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(2), "timeout")
		VarsGlobal.GameInterface.start_dialog("annette-prefight")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		VarsGlobal.GameScenario.get_node("Boss/Annette1").start_battle()
		yield(get_tree().create_timer(2), "timeout")
		VarsGlobal.GameInterface.can_pause = true
		VarsGlobal.Player.set_enabled_input(true)
