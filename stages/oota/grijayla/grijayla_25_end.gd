extends Control

func _ready() -> void :
	
	Achievments.obtain_ach("ach1")
	
	Audio.underwater_filter_enabled(true)
	Audio.play_voice("xandria_coff")
	
	
	yield(get_tree().create_timer(0.5), "timeout")
	yield(get_tree(), "idle_frame")
	
	
	
	var Tw: = create_tween()
	
	Tw.tween_property(
		VarsGlobal.GameScenario.CameraNode, "zoom", Vector2(0.5, 0.5), 10
	).set_ease(Tween.EASE_IN_OUT)
	
	
	VarsGlobal.Player.change_state("suffocation")
	
	yield(get_tree().create_timer(2), "timeout")
	Audio.play_voice("xandria_extra_damage1")
	
	yield(get_tree().create_timer(2), "timeout")
	Audio.play_voice("xandria_extra_damage3")
	
	yield(get_tree().create_timer(2), "timeout")
	Audio.play_voice("xandria_extra_damage2")
	
	yield(get_tree().create_timer(3), "timeout")
	Audio.play_voice("xandria_death_fall")
	VarsGlobal.Player.change_state("death-floor")
	
	yield(get_tree().create_timer(1), "timeout")

	$CanvasLayer / AnimationPlayer.play_backwards("fadeout")
	yield($CanvasLayer / AnimationPlayer, "animation_finished")
	
	Audio.stop_sfx("ui_gas_loop")
	Audio.underwater_filter_enabled(false)
	yield(get_tree().create_timer(2), "timeout")
	SceneChanger.change_scene("res://stages/oota/prologue/prologue_ending.tscn")
