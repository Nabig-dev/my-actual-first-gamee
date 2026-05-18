extends Node

func _ready() -> void :
	
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.has_flag("defeated_boss_sheal") == false:
		Audio.stop_music()
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.Player.stop_move()
		VarsGlobal.Player.move(Vector2.RIGHT)
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(2), "timeout")
		Audio.play_music("before_dirian_sheal")
		VarsGlobal.GameInterface.start_dialog("sheal-prebattle")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		VarsGlobal.GameScenario.get_node("Boss/Sheal").start_battle()
