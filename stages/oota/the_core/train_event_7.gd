extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	VarsGlobal.GameInterface.connect(
		"dialog_signal_emitted", self, "_on_dialogsignal"
	)

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.Player.move(Vector2.LEFT)
	yield(get_tree().create_timer(0.5), "timeout")
	VarsGlobal.Player.jump()
	VarsGlobal.Player.move(Vector2.LEFT)

func _on_dialogsignal(_dialogname: String, _signalname: String) -> void :
	Audio.play_sfx("ui_accept")
	
	VarsGlobal.current_room_changer = ""
	VarsGlobal.current_building_door = ""
	VarsGlobal.game_data.current_room_changer = ""
	VarsGlobal.game_data.current_building_door = ""
	SceneChanger.change_scene("res://stages/oota/the_core/amerithia_central.tscn")

func _on_InteractableArea2DIndicator_interact_requested() -> void :
	VarsGlobal.GameInterface.start_dialog("cancel-train-event")
