extends CanvasLayer

var player_no_death: bool

var using_console: bool

var _moving_player: bool

func _ready() -> void :

	if Features.has("debug") == false:
		visible = false
		return
	
	get_tree().call_group("debug_label", "set_visible", false)
	
	get_node("%BtnOpenMenu").visible = not Features.has("pc")
	
	get_node("%Menu").visible = false

	get_node("%FPSMonitor").enable_monitor(
		get_node("%ChkBxShowFPS").pressed
	)
	get_node("%GamepadInput").visible = get_node("%ChkBxShowInput").pressed
	
	get_node("%LineChangeToPath").text = get_tree().current_scene.filename
	get_node("%BtnSelectScenarioToChange").text = get_node("%BtnSelectScenarioToChange").text.get_file()
	get_node("%LblCurrentScene").text = get_node("%BtnSelectScenarioToChange").text.get_file()
	
func _input(event: InputEvent) -> void :
	
	if visible == false:
		return
	
	if (
		event is InputEventKey
		and event.is_echo() == false
		and event.is_pressed() == true
	):
		if event.scancode == KEY_ESCAPE and using_console == false:
			get_node("%Menu").visible = not get_node("%Menu").visible
		elif event.scancode == KEY_ESCAPE:
			if using_console == true:
				get_node("%LnCommandConsole").release_focus()
			elif get_node("%Menu").visible == true:
				get_node("%Menu").visible = false

func _process(delta: float) -> void :
	if _moving_player == true:
		if Input.is_action_pressed("ui_up"):
			VarsGlobal.Player.translate(Vector2.UP * 200 * delta)
		elif Input.is_action_pressed("ui_down"):
			VarsGlobal.Player.translate(Vector2.DOWN * 200 * delta)
		elif Input.is_action_pressed("ui_left"):
			VarsGlobal.Player.translate(Vector2.LEFT * 200 * delta)
		elif Input.is_action_pressed("ui_right"):
			VarsGlobal.Player.translate(Vector2.RIGHT * 200 * delta)
		

func _on_BtnSelectScenarioToChange_pressed() -> void :
	get_node("%FileDialogOpenScenario").set_current_dir(
		"res://stages/oota/"
	)
	get_node("%FileDialogOpenScenario").popup()
	get_node("%FileDialogOpenScenario").rect_position = Vector2.ZERO

func _on_FileDialogOpenScenario_file_selected(path: String) -> void :
	Audio.play_sfx("ui_changed_value2")
	get_node("%LineChangeToPath").text = path
	get_node("%BtnSelectScenarioToChange").text = path.get_file()

func _on_BtnGoToPath_pressed() -> void :
	Audio.play_sfx("ui_accept")
	SceneChanger.change_scene(get_node("%LineChangeToPath").text)
	get_node("%LblCurrentScene").text = get_node("%LineChangeToPath").text.get_file()

func _on_ChkBxShowFPS_toggled(button_pressed: bool) -> void :
	Audio.play_sfx("ui_changed_value2")
	get_node("%FPSMonitor").enable_monitor(button_pressed)

func _on_BtnOpenMenu_pressed() -> void :
	get_node("%Menu").visible = not get_node("%Menu").visible

func _on_ChkBxShowInput_toggled(button_pressed: bool) -> void :
	Audio.play_sfx("ui_changed_value2")
	get_node("%GamepadInput").visible = button_pressed

func _on_ChkBxMovePlayer_toggled(button_pressed: bool) -> void :
	Audio.play_sfx("ui_changed_value2")
	if button_pressed == true:
		VarsGlobal.Player.set_physics_process(false)
	else:
		VarsGlobal.Player.set_physics_process(true)
	
	_moving_player = button_pressed

func _on_BtnFullHP_pressed() -> void :
	VarsGlobal.game_data["player_hp_now"] = VarsGlobal.game_data["player_hp_max"]
	Audio.play_sfx("ui_success")
	VarsGlobal.GameInterface.update_hud_values(false)
func _on_BtnFullMP_pressed() -> void :
	VarsGlobal.game_data["player_mp_now"] = VarsGlobal.game_data["player_mp_max"]
	Audio.play_sfx("ui_success")
	VarsGlobal.GameInterface.update_hud_values(false)
func _on_BtnFullBL_pressed() -> void :
	VarsGlobal.game_data["player_bl_now"] = VarsGlobal.game_data["player_bl_max"]
	Audio.play_sfx("ui_success")
	VarsGlobal.GameInterface.update_hud_values(false)
func _on_BtnFullClearNegativeStatus_pressed() -> void :
	VarsGlobal.game_data["player_injured"] = false
	VarsGlobal.game_data["player_poisoned"] = false
	VarsGlobal.game_data["player_cursed"] = false
	Audio.play_sfx("ui_success")
	VarsGlobal.GameInterface.update_hud_values(false)

func _on_ChkBxNoDeath_toggled(button_pressed: bool) -> void :
	Audio.play_sfx("ui_changed_value2")
	player_no_death = button_pressed

func _on_LnCommandConsole_focus_entered() -> void :
	using_console = true
func _on_LnCommandConsole_focus_exited() -> void :
	using_console = false
	get_node("%LnCommandConsole").text = ""
func _on_LnCommandConsole_text_entered(new_text: String) -> void :
	
	if new_text.begins_with("sethp"):
		VarsGlobal.game_data["player_hp_now"] = int(
			new_text.replace("sethp", "")
		)
	elif new_text.begins_with("setatk"):
		VarsGlobal.game_data["player_atk"] = int(
			new_text.replace("setatk", "")
		)
	elif new_text.begins_with("setdef"):
		VarsGlobal.game_data["player_def"] = int(
			new_text.replace("setdef", "")
		)
	elif new_text.begins_with("setint"):
		VarsGlobal.game_data["player_int"] = int(
			new_text.replace("setint", "")
		)
	elif new_text.begins_with("setlvl"):
		VarsGlobal.game_data["current_level"] = int(
			new_text.replace("setlvl", "")
		)
	elif new_text.begins_with("setexp"):
		VarsGlobal.game_data["exp"] = int(
			new_text.replace("setexp", "")
		)
	elif new_text.begins_with("char"):
		VarsGlobal.current_player_char = new_text.replace("char", "").strip_edges()
	
	elif new_text.begins_with("set ach"):
		Achievments.obtain_ach(new_text.replace("set ach", "").strip_edges())
	
	elif new_text == "onehp":
		VarsGlobal.game_data["player_hp_now"] = 1
	
	elif new_text == "get gamedata":
		
		OS.set_clipboard(JSON.print(VarsGlobal.game_data))
	
	elif new_text == "set gamedata":
		var gamedata: String = OS.get_clipboard()
		VarsGlobal.game_data = VarsGlobal.get_dict_parsed_fixed(
			JSON.parse(gamedata).result
		)

	else:
		Audio.play_sfx("ui_incorrect")
		return
	
	
	
	
	Audio.play_sfx("ui_success")
	VarsGlobal.GameInterface.update_hud_values(false)
	get_node("%LnCommandConsole").text = ""

func _on_ChkBxPause_toggled(button_pressed: bool) -> void :
	Audio.play_sfx("ui_changed_value2")
	get_tree().paused = button_pressed

func _on_ChkBxDebugLabel_toggled(button_pressed: bool) -> void :
	Audio.play_sfx("ui_changed_value2")
	get_tree().call_group("debug_label", "set_visible", button_pressed)
