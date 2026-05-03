extends Control

var _showing_xandria: bool

func _ready() -> void :
	Audio.play_music("prologue_intro", "high", 5)
	$AnimationPlayer4.play("show_text")
	
	yield(get_tree().create_timer(37), "timeout")
	if _showing_xandria == false:
		_show_xandria()

func _process(_delta: float) -> void :
	if Input.is_action_just_pressed("ui_start"):
		_skip()

func _skip() -> void :
	if _showing_xandria == false:
		_show_xandria()
		for m in Audio.Musics:
			if m.name == "prologue_intro":
				m.get_children()[0].play(37.7)
	else:
		
		get_node("%HBxSkip").visible = false
		set_process(false)
		Audio.stop_music()
		
		_on_Timer_timeout()

func _show_xandria() -> void :
	if _showing_xandria == true:
		return
	_showing_xandria = true
	$AnimationPlayer4.play("hide_hermes")
	$Timer.start()
	$AnimationPlayer.play("show")
	$AnimationPlayer2.play("show")
	$AnimationPlayer3.play("show")

func _on_Timer_timeout() -> void :
	$AnimationPlayer.playback_speed = 1
	$AnimationPlayer.play_backwards("show")
	yield($AnimationPlayer, "animation_finished")
	SceneChanger.change_scene("res://stages/oota/prologue/horses_scene.tscn")

func _on_ButtonSkip_pressed() -> void :
	_skip()
