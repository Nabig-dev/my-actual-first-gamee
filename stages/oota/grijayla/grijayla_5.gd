extends Node

var _pyro_applied: bool
var _tuto_dialog_ended: bool

func _ready() -> void :

	if VarsGlobal.has_flag("howto_use_circuit_action_tuto") == true:
		VarsGlobal.GameScenario.get_node("PuzzleExplosion").queue_free()
		
	VarsGlobal.GameInterface.connect("dialog_signal_emitted", self, "_on_dialog_signal")

	yield(get_tree().create_timer(0.9), "timeout")
	
	if VarsGlobal.has_flag("whip_m_tuto_finished") == false:
		VarsGlobal.game_data["player_bl_now"] = VarsGlobal.game_data["player_bl_max"]
		VarsGlobal.GameInterface.update_hud_values(false)
		Savedata.update_flag_game("whip_m_tuto_finished")
		VarsGlobal.GameInterface.show_tuto_screen(4)
	
	if VarsGlobal.has_flag("gueguense_cutscene_played") == true:
		_on_AnimationPlayerCutscene_animation_finished("show", 0)
	


func _on_Area2DStartCutscene_area_entered(_area: Area2D) -> void :

	if VarsGlobal.has_flag("gueguense_cutscene_played") == true:
		return
	
	Audio.play_music("beginning_of_darkness", "low")
	
	VarsGlobal.GameScenario.get_node("DoorSacrifice").door_locked = true
	
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.GameInterface.can_pause = false
	
	VarsGlobal.Player.move(Vector2.LEFT)
	
	VarsGlobal.GameScenario.CameraNode.move_to(
		VarsGlobal.GameScenario.get_node("Cutscene/Position2DCamera").global_position, 3
	)
	
	VarsGlobal.GameScenario.get_node("Cutscene/AnimationPlayerCutscene").play("show")

func _on_Area2DStopPlayer_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("gueguense_cutscene_played") == true:
		return
	VarsGlobal.add_flag("gueguense_cutscene_played")
	VarsGlobal.Player.stop_move()


func _on_AnimationPlayerCutscene_animation_finished(anim_name: String, camera_return: float = 0.1) -> void :
	if anim_name == "show":
		
		Audio.play_music("beginning_of_darkness", "high")
		
		VarsGlobal.Player.set_enabled_input(true)
		VarsGlobal.GameInterface.can_pause = true
		if camera_return > 0:
			VarsGlobal.GameScenario.CameraNode.return_to_player(camera_return)
		
		if VarsGlobal.GameScenario.get_node_or_null("Enemies/GueguenseDark") != null:
			VarsGlobal.GameScenario.get_node("Enemies/GueguenseDark").global_position = VarsGlobal.GameScenario.get_node("Cutscene/GueguenseDark/Position2D").global_position
		if VarsGlobal.GameScenario.get_node_or_null("Enemies/GueguenseDark2") != null:
			VarsGlobal.GameScenario.get_node("Enemies/GueguenseDark2").global_position = VarsGlobal.GameScenario.get_node("Cutscene/GueguenseDark2/Position2D").global_position
		
		VarsGlobal.GameScenario.get_node("Cutscene/GueguenseDark").visible = false
		VarsGlobal.GameScenario.get_node("Cutscene/GueguenseDark2").visible = false



func _on_dialog_ended(_dialog: String) -> void :
	VarsGlobal.Player.set_enabled_input(true)
	VarsGlobal.GameInterface.can_pause = true



func _on_AreaDetectPlayerWeaponAttrbs_attr_detected(attrb_elemental: Array) -> void :
	if attrb_elemental.has("pyro") == true and _pyro_applied == false:
		_pyro_applied = true
		yield(get_tree().create_timer(3), "timeout")
		VarsGlobal.GameInterface.show_flash()
		Savedata.update_flag_game("howto_use_circuit_action_tuto")
		yield(get_tree(), "idle_frame")
		Audio.play_sfx("impact_body_wall")
		Audio.play_sfx("explosion_grijayla_cinematic")
		Gamepad.start_vibration(0, 1.0, 1.0, 1.5)
		VarsGlobal.GameScenario.CameraNode.start_shake(
			0.9, true, true
		)
		VarsGlobal.GameScenario.get_node("PuzzleExplosion/SpriteExplosion").play("default")
		VarsGlobal.GameScenario.get_node("PuzzleExplosion/ParticlesRocks").emitting = true
		VarsGlobal.GameScenario.get_node("PuzzleExplosion/Body").queue_free()


func _on_InteractableArea2DIndicator_interact_requested() -> void :
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	VarsGlobal.GameInterface.can_pause = false
	yield(get_tree().create_timer(0.5), "timeout")
	VarsGlobal.GameInterface.start_dialog("grijayla-about-explosive-tank")

func _on_dialog_signal(_dialog: String, signal_name: String) -> void :
	if signal_name == "show_tuto_circuits" and VarsGlobal.has_flag("howto_use_circuit_action_tuto") == false:
		_tuto_dialog_ended = true
		yield(get_tree(), "idle_frame")
		yield(get_tree().create_timer(0.5), "timeout")
		VarsGlobal.GameInterface.show_tuto_screen(10)
		yield(VarsGlobal.GameInterface, "dialog_ended")
		VarsGlobal.Player.set_enabled_input(true)
		VarsGlobal.GameInterface.can_pause = true



func _on_DoorSacrifice_sacrifice_completed() -> void :
	VarsGlobal.GameScenario.get_node("Enemies/GueguenseDark").queue_free()
	


func _on_HurtboxExplosiveTank_area_entered(_area: Area2D) -> void :
	if _pyro_applied == true or _tuto_dialog_ended == false:
		return
	if VarsGlobal.GameScenario.get_node("PuzzleExplosion/TimerCoolDown").is_stopped():
		VarsGlobal.GameScenario.get_node("PuzzleExplosion/TimerCoolDown").start()
		VarsGlobal.GameInterface.show_quick_text(
			"DLGIMUSTUSEPYRO", VarsGlobal.Player
		)
