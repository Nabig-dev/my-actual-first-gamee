extends Node

func _ready() -> void :
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.has_flag("defeated_boss_elisia") == false:
		Audio.stop_music()
		VarsGlobal.GameScenario.get_node("elsa").HurtboxEnemy.connect(
			"defeated", self, "_on_defeat"
		)
		
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)
		yield(get_tree().create_timer(2), "timeout")
		Audio.play_music("before_elisia")
		VarsGlobal.Player.stop_move()
		VarsGlobal.Player.move(Vector2.RIGHT)
		yield(get_tree().create_timer(1.8), "timeout")
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(2), "timeout")
		VarsGlobal.GameInterface.start_dialog("elsa-prebattle")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		VarsGlobal.GameScenario.get_node("elsa").start_battle()
		yield(get_tree().create_timer(2), "timeout")
		VarsGlobal.GameInterface.can_pause = true
		VarsGlobal.Player.set_enabled_input(true)

func _on_defeat() -> void :
	if VarsGlobal.game_data["player_hp_now"] < 1:
		return
	
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.Player.invencibility(3, false)
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	yield(get_tree().create_timer(2), "timeout")
	Audio.play_music("after_elisia")
	VarsGlobal.GameInterface.start_dialog("elsa-defeated")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	
	VarsGlobal.GameScenario.get_node("elsa").AnimPlayer.play("defeated")
