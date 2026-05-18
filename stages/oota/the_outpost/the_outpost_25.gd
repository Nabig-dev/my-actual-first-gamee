extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	if VarsGlobal.has_flag("eva_1st_fight_ended") == false:
		Audio.stop_music()
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)

		VarsGlobal.GameInterface.connect("dialog_ended", self, "_on_dialog_ended")

		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.Player.move(Vector2.RIGHT)
		yield(get_tree().create_timer(2), "timeout")
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.GameScenario.get_node("DoorBoss2").open_door()
		Audio.play_music("before_isaac_eva")
		
		VarsGlobal.GameScenario.get_node("Eve").Enemy.change_state("walk")
		yield(get_tree().create_timer(2.0), "timeout")
		VarsGlobal.Player.backdash()
		yield(get_tree().create_timer(0.7), "timeout")
		VarsGlobal.GameScenario.get_node("Eve").Enemy.change_state("idle")
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(0.5), "timeout")
		VarsGlobal.GameScenario.get_node("DoorBoss2").close_door()
		yield(get_tree().create_timer(2), "timeout")
		VarsGlobal.GameInterface.start_dialog("the_outpost-eve-beforebattle")

func _on_dialog_ended(dialog: String) -> void :
	if dialog == "the_outpost-eve-beforebattle":
		VarsGlobal.GameInterface.can_pause = true
		VarsGlobal.Player.set_enabled_input(true)
		VarsGlobal.GameScenario.get_node("Eve").start_battle()

	elif dialog == "the_outpost-eve-battle-ended":
		yield(get_tree().create_timer(1), "timeout")
		
		Audio.play_voice("eva_laugh")
		
		Audio.play_sfx("ui_gas_loop")
		VarsGlobal.GameScenario.get_node("CPUParticlesGas").emitting = true
		VarsGlobal.GameScenario.get_node("GasAtkFade/AnimationPlayer").play("fade")
		VarsGlobal.GameScenario.get_node("Eve").Enemy.change_state("lastatk")
		yield(get_tree().create_timer(1), "timeout")
		
		Audio.play_voice("xandria_coff")
		VarsGlobal.game_data["player_poisoned"] = true
		VarsGlobal.GameInterface.apply_negative_status("POISONED")
		VarsGlobal.GameInterface.update_hud_values(false)
		VarsGlobal.Player.set_enabled_input(true)
		VarsGlobal.Player.invencibility(10, false)
		yield(get_tree().create_timer(2), "timeout")
		Audio.play_voice("xandria_extra_damage2")
		yield(get_tree().create_timer(3), "timeout")
		
		VarsGlobal.GameInterface.show_quick_text(
			"DLG1_1675878395", VarsGlobal.Player
		)
	
	else:
		Audio.underwater_filter_enabled(true)

func _on_Eva_battle_ended() -> void :
	VarsGlobal.add_flag("eva_1st_fight_ended")
	Audio.play_voice("eva_damage")
	Audio.stop_music()
	
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.invencibility(10, false)
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.GameInterface.show_flash()
	Audio.play_music("after_isaac_eva")
	yield(get_tree().create_timer(3), "timeout")
	VarsGlobal.GameInterface.start_dialog("the_outpost-eve-battle-ended")

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void :
	SceneChanger.change_scene("res://stages/oota/the_outpost/grijayla_25_end.tscn")
