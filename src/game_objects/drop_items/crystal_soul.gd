extends Node2D

func crystal_get() -> void :
	
	VarsGlobal.game_data["player_hp_now"] = VarsGlobal.game_data["player_hp_max"]
	VarsGlobal.game_data["player_mp_now"] = VarsGlobal.game_data["player_mp_max"]
	VarsGlobal.GameInterface.update_hud_values(false)
	
	yield(get_tree().create_timer(1.2), "timeout")
	get_tree().paused = false
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.GameInterface.emit_signal("boss_orb_obtained")
	queue_free()

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void :
	VarsGlobal.GameInterface.show_flash()
	$AnimationPlayer.play("idle")
	Audio.play_sfx("crystal_soul_generated")

func _on_Area2D_area_entered(_area: Area2D) -> void :
	$AnimationPlayer.play("get")
	Audio.play_sfx("crystal_soul_get")
	get_tree().paused = true
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.GameInterface.update_hud_values(false)


func _on_TimerDelay_timeout() -> void :
	$AnimationPlayer.play("show")
	Audio.play_sfx("crystal_soul_generating")
