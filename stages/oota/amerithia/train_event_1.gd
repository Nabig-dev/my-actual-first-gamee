extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")

	VarsGlobal.GameInterface.connect(
		"dialog_signal_emitted", self, "_on_dialogsignal"
	)

	if VarsGlobal.has_flag("train_event1_start") == false:
		Audio.stop_music()
		Audio.play_sfx("train_start")
		VarsGlobal.add_flag("train_event1_start")
	
	else:
		VarsGlobal.GameScenario.get_node("TimerTrainShake").stop()
		$ColorRect.visible = false
		VarsGlobal.Player.set_enabled_input(true)
		return
	
	VarsGlobal.GameInterface.can_pause = false
	
	VarsGlobal.Player.change_state("sit", true, false)
	yield(get_tree().create_timer(3), "timeout")
	Audio.play_music("ambient_forest_wind")
	Audio.play_sfx("train_loop")
	$AnimationPlayer.play("show")
	
	yield($AnimationPlayer, "animation_finished")
	
	var Dialog = Dialogic.start("xandria-in-train1")
	Dialog.connect("dialogic_signal", self, "_on_dialogic_signal")
	Dialog.connect("timeline_end", self, "_on_dialog_end")
	add_child(Dialog)

func _on_dialogic_signal(event: String) -> void :
	if event == "explosion":
		Audio.play_music("train_assault")
		VarsGlobal.GameInterface.show_flash()
		Audio.play_sfx("explosion_grijayla_cinematic")
		VarsGlobal.GameScenario.CameraNode.start_shake(
			1, true, true
		)
		Gamepad.start_vibration(0, 0.8, 0.8, 0.1)

func _on_dialog_end(_dialog) -> void :
	Audio.play_music("train_assault")
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.change_state("idle", true, false)
	VarsGlobal.Player.set_enabled_input(true)
	Audio.stop_sfx("train_loop")

func _on_TimerTrainShake_timeout() -> void :
	VarsGlobal.GameScenario.CameraNode.start_shake(
		0.2, false, true
	)
	Gamepad.start_vibration(0, 0.4, 0.6, 0.2)


func _on_Node_tree_exiting() -> void :
	
	Gamepad.start_vibration(0, 0.1, 0.1, 0.1)


func _on_dialogsignal(_dialogname: String, _signalname: String) -> void :
	Audio.play_sfx("ui_accept")
	
	VarsGlobal.current_room_changer = ""
	VarsGlobal.current_building_door = ""
	VarsGlobal.game_data.current_room_changer = ""
	VarsGlobal.game_data.current_building_door = ""
	SceneChanger.change_scene("res://stages/oota/amerithia/amerithia_central.tscn")

func _on_InteractableArea2DIndicator_interact_requested() -> void :
	VarsGlobal.GameInterface.start_dialog("cancel-train-event")
