extends Node

func _ready() -> void :
	if VarsGlobal.has_flag("train_event_finished"):
		$GameScenario / AlessaEvent.queue_free()

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	Audio.stop_music()
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	yield(get_tree().create_timer(1), "timeout")
	
	Audio.play_music("alessa_theme")
	
	if VarsGlobal.has_flag("alessa_talk_office1") == false:
		VarsGlobal.GameInterface.start_dialog("alessa-train-reminder")
	else:
		VarsGlobal.GameInterface.start_dialog("alessa-train-reminder2")
	
	yield(VarsGlobal.GameInterface, "dialog_ended")
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	
	Audio.play_music("grey_woods")

func _on_AreaDetectPlayerExit_area_entered(_area: Area2D) -> void :
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	Input.action_release("ui_down")
	
	yield(get_tree().create_timer(1), "timeout")

	VarsGlobal.GameInterface.start_dialog("alessa-train-nopass")
	
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	VarsGlobal.Player.move(Vector2.RIGHT)
	
	yield(get_tree().create_timer(1.5), "timeout")
	
	VarsGlobal.Player.stop_move()
	yield(get_tree().create_timer(0.5), "timeout")
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
