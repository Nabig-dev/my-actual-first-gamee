extends Node2D

var _destroyed: bool = false

func _ready() -> void :
	if VarsGlobal.game_data["player_key_objects"].has(
		GVar.KEYS_OBJECTS.ORNAMENT_GEMSTONE
	) == true and VarsGlobal.has_flag("statue_obstacle_destroyed") == true:
		_destroyed = true
		$AnimationPlayer.play("destroyed")

func _rumble() -> void :
	Audio.play_sfx("impact_mineral3")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.3, false, true)
	Gamepad.start_vibration(0, 0.3, 0.3, 0.5)

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	
	if _destroyed == true:
		return
	
	
	if VarsGlobal.game_data["player_key_objects"].has(
		GVar.KEYS_OBJECTS.ORNAMENT_GEMSTONE
	) == true:
		_destroyed = true
		$AnimationPlayer.play("destroy")
		Audio.play_sfx("ui_changed_value3")
		Audio.play_sfx("light_flash2")
		VarsGlobal.add_flag("statue_obstacle_destroyed")
	
	
	else:
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.stop_move()
		VarsGlobal.Player.invencibility(1.3, false)
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.GameInterface.start_dialog("statue-obstacle")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		VarsGlobal.Player.set_enabled_input(true)
		VarsGlobal.GameInterface.can_pause = true
