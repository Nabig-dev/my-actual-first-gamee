extends Node



func _on_AreaStartBattle_area_entered(_area: Area2D) -> void :
	
	if VarsGlobal.game_data["flags"].has("defeated_boss_aquapriestess") == true:
		return
	Audio.stop_music()
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	yield(get_tree().create_timer(3), "timeout")
	VarsGlobal.GameScenario.get_node("AquaPriestess").start_battle()
