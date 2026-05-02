extends Node






func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	
	VarsGlobal.GameScenario.CameraNode.connect("tweened_to_position", self, "_on_camera_tweened_to_position")
	VarsGlobal.GameScenario.CameraNode.connect("tweened_to_player", self, "_on_camera_tweened_to_player")
	
	if VarsGlobal.has_flag("xandria_talked_with_atreu_grijayla") == false:
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)
		Audio.stop_music()
		VarsGlobal.GameScenario.get_node("ShadowGradient0").visible = true
		
		VarsGlobal.game_data["last_save_room_used"] = "res://stages/oota/grijayla_13.tscn"
	else:
		remove_gameplay_block()
	
	
	if VarsGlobal.has_flag("grijayla12_player_entered_boss_room") == true:
		VarsGlobal.GameScenario.get_node("Calcite").queue_free()
	else:
		for c in VarsGlobal.GameScenario.get_node("Calcite").get_children():
			c.connect("impacted", self, "_on_CalcitaImpacted")

func remove_gameplay_block() -> void :
	VarsGlobal.GameScenario.get_node("ShadowGradient0").visible = false
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)

func _on_Area2DDetectPlayerStartFlashback_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("xandria_talked_with_atreu_grijayla") == true:
		return
	VarsGlobal.GameInterface.connect("dialog_ended", self, "_on_dialog_ended")
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.GameInterface.can_pause = false
	
	Audio.play_music("xandrias_theme")
	Audio.play_sfx("impact_mineral")
	VarsGlobal.Player.change_state("crouch", true)
	VarsGlobal.Player.move(Vector2.LEFT)
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.GameInterface.start_dialog("grijayla-flashback-before-atreu")
	VarsGlobal.GameScenario.get_node("AtreuCinematic").visible = true

func _on_dialog_ended(dialog: String) -> void :
	
	match dialog:
		"grijayla-flashback-before-atreu":
			Audio.play_music("beginning_of_darkness_underground")
			remove_gameplay_block()
			VarsGlobal.Player.change_state("idle")
			
			VarsGlobal.Player.set_enabled_input(false)
			VarsGlobal.GameInterface.can_pause = false
			
			
			
			yield(get_tree().create_timer(1), "timeout")
			VarsGlobal.GameScenario.get_node("AtreuCinematic/AnimationPlayer").play("atreu")
			yield(get_tree().create_timer(6), "timeout")
			
			VarsGlobal.GameInterface.start_dialog("grijayla-prologue-atreu-go")
		
		"grijayla-prologue-atreu-go":
			VarsGlobal.add_flag("xandria_talked_with_atreu_grijayla")
			remove_gameplay_block()
			VarsGlobal.Player.set_enabled_input(false)
			VarsGlobal.GameInterface.can_pause = false
			VarsGlobal.GameScenario.CameraNode.move_to(
				VarsGlobal.GameScenario.get_node("DoorBoss").global_position + Vector2(100, - 50), 3
			)
		"grijayla-after-atreu":
			VarsGlobal.Player.change_state("idle")
			VarsGlobal.Player.set_enabled_input(true)
			VarsGlobal.GameInterface.can_pause = true

func _on_camera_tweened_to_position() -> void :
	yield(get_tree().create_timer(0.5), "timeout")
	VarsGlobal.GameScenario.CameraNode.return_to_player(2)

func _on_camera_tweened_to_player() -> void :
	yield(get_tree().create_timer(0.5), "timeout")
	
	VarsGlobal.Player.move(Vector2.RIGHT)
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.Player.whip_attack()
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.Player.whip_attack()
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.Player.whip_attack()
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.Player.crouch()
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.GameInterface.start_dialog("grijayla-after-atreu")


func _on_RoomChanger3_body_entered(_body: Node) -> void :
	if VarsGlobal.has_flag("grijayla12_player_entered_boss_room") == false:
		VarsGlobal.add_flag("grijayla12_player_entered_boss_room")
		


func _on_CalcitaImpacted() -> void :
	if VarsGlobal.GameScenario.get_node("TimerCarbonMsgCooldown").is_stopped() == false:
		return
	VarsGlobal.GameScenario.get_node("TimerCarbonMsgCooldown").start(5)
	var current_alloy: int = VarsGlobal.game_data["player_ec_alloy_selected"][
			VarsGlobal.game_data["player_current_set"]
	]
	var has_carbon: bool = VarsGlobal.game_data["player_ec_alloy"].has(
		GVar.ALLOYS.C
	)
	
	if has_carbon and current_alloy != GVar.ALLOYS.C:
		VarsGlobal.GameInterface.show_quick_text(
			"DLGIMUSTUSECARBON", VarsGlobal.Player
		)
