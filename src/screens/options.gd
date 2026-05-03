extends Control





var _can_change_tabs: bool = true

var _tabs_nodes: Array

onready var NodeTabContainer = $Margin / TabContainer

onready var SliderSfx = $Margin / TabContainer / AUDIO / ScrollContainer / Margin / VBox / HBox_sfx / HSlider
onready var SliderBgm = $Margin / TabContainer / AUDIO / ScrollContainer / Margin / VBox / HBox_bgm / HSlider
onready var SliderVoice = $Margin / TabContainer / AUDIO / ScrollContainer / Margin / VBox / HBox_voice / HSlider

func _ready() -> void :
	
	_ui_btns_have_conflict()

	if Gamepad.is_connected(
		"gamepad_connection_changed", self, 
		"_on_GamepadConnection"
	) == false:
		
		Gamepad.connect(
			"gamepad_connection_changed", self, 
			"_on_GamepadConnection"
		)
	_on_GamepadConnection(
		Gamepad.is_controller_connected()
	)

	_tabs_nodes = NodeTabContainer.get_children()
	_on_TabContainer_tab_changed(NodeTabContainer.current_tab)
	
	
	_on_BtnLang_value_changed(
		"_btn_name", false, Config.get_value("gameplay", "lang", "en"), "_section", "_key"
	)
	
	
	if Features.has("mobile") == true:
		$Margin / TabContainer / GAMEPLAY / ScrollContainer / Margin / VBox / BtnIconAction.visible = false
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnVisualMode.visible = false
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnResolution.visible = false
		$Margin / TabContainer / GAMEPAD / ScrollContainer / Margin / VBox / BtnGmpdVibrt.visible = false
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnScreenFilter.visible = false
		
		NodeTabContainer.set_tab_hidden(4, true)
		_tabs_nodes.remove(4)
	
	else:
		$Margin / TabContainer / GAMEPLAY / ScrollContainer / Margin / VBox / BtnUseVirtualJoystick.visible = false
		$Margin / TabContainer / GAMEPLAY / ScrollContainer / Margin / VBox / BtnAlwaysShowVpad.visible = false
		
		$Margin / TabContainer / GAMEPLAY / ScrollContainer / Margin / VBox / BtnEditTouchButtons.visible = false
	
	
	if Features.has("pc") == false:
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnVisualMode.visible = false
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnResolution.visible = false
		$Margin / TabContainer / GAMEPAD / ScrollContainer / Margin / VBox / BtnGmpdVibrt.visible = false
	
	else:
		pass
	
	
	if (
		Config.get_value("video", "visual_mode", "windowed") == "fullscreen"
		and Features.has("pc") == true
	):
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnResolution.visible = false
	elif Features.has("pc") == true:
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnResolution.visible = true
	
	
	
	if (
		Features.has("switch")
		or Features.has("xbox")
		or Features.has("ps")
		
	):
		
		$Margin / TabContainer / GAMEPLAY / ScrollContainer / Margin / VBox / BtnIconAction.visible = false
		
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnVisualMode.visible = false
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnResolution.visible = false
		
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnFPSLimit.visible = false
		
		$Margin / TabContainer / GAMEPAD / ScrollContainer / Margin / VBox / BtnGmpdMapping.visible = false
		


		
		$Margin / TabContainer / GAMEPAD / ScrollContainer / Margin / VBox / BtnCustomIconsBtns.visible = false
		
		
		
		$Margin / TabContainer / GAMEPAD / ScrollContainer / Margin / VBox / BtnGmpdMapping.visible = false
		$Margin / TabContainer / GAMEPAD / ScrollContainer / Margin / VBox / BtnChangeScheme.visible = false
		
		$Margin / TabContainer / GAMEPAD / ScrollContainer / Margin / VBox / Grid / ButtonRemap8.visible = false
		$Margin / TabContainer / GAMEPAD / ScrollContainer / Margin / VBox / Grid / ButtonRemap9.visible = false
		
		$Margin / TabContainer / GAMEPAD / ScrollContainer / Margin / VBox / Grid / ButtonRemap14.visible = false
		$Margin / TabContainer / GAMEPAD / ScrollContainer / Margin / VBox / Grid / ButtonRemap15.visible = false
	
		
		NodeTabContainer.set_tab_hidden(4, true)
		_tabs_nodes.remove(4)
	
	
	
	
	
	
	


	
	
	SliderSfx.value = Config.get_value("audio", "sfx", 1.0) * 100
	$Margin / TabContainer / AUDIO / ScrollContainer / Margin / VBox / HBox_sfx / LblNum.text = String(SliderSfx.value).pad_zeros(0)
	SliderSfx.connect("value_changed", self, "_on_AudioHSlider_value_changed", ["sfx"])
	
	SliderBgm.value = Config.get_value("audio", "bgm", 1.0) * 100
	$Margin / TabContainer / AUDIO / ScrollContainer / Margin / VBox / HBox_bgm / LblNum.text = String(SliderBgm.value).pad_zeros(0)
	SliderBgm.connect("value_changed", self, "_on_AudioHSlider_value_changed", ["bgm"])
	
	SliderVoice.value = Config.get_value("audio", "voice", 1.0) * 100
	$Margin / TabContainer / AUDIO / ScrollContainer / Margin / VBox / HBox_voice / LblNum.text = String(SliderVoice.value).pad_zeros(0)
	SliderVoice.connect("value_changed", self, "_on_AudioHSlider_value_changed", ["voice"])
	
	
	var remap_buttons = $Margin / TabContainer / GAMEPAD / ScrollContainer / Margin / VBox / Grid.get_children()
	
	remap_buttons.append_array($Margin / TabContainer / KEYBOARD / ScrollContainer / Margin / VBox / Grid.get_children())

	for b in remap_buttons:
		if b.is_in_group("remap_button") == true:
			b.connect("remap_started", self, "_on_Btn_remap_started")
			
			b.connect("remap_updated", self, "_on_Btn_remap_closed")
			b.connect("remap_canceled", self, "_on_Btn_remap_closed")

func _process(_delta: float) -> void :
	
	if _can_change_tabs and Input.is_action_just_pressed("ui_cancel"):
		_on_BtnMainMenu_pressed()
	if _can_change_tabs and Input.is_action_just_pressed("ui_focus_prev"):
		_select_new_tab("prev")
		Audio.play_sfx("ui_big_btn_focused")
	if _can_change_tabs and Input.is_action_just_pressed("ui_focus_next"):
		_select_new_tab("next")
		Audio.play_sfx("ui_big_btn_focused")

func _select_new_tab(direction: String) -> void :
	var new_tab: int = FuncsArrays.get_new_position_on_array(
		_tabs_nodes, NodeTabContainer.current_tab, direction
	)
	NodeTabContainer.current_tab = new_tab



func _on_TabContainer_tab_changed(tab: int) -> void :
	
	var selected_tab_node: Tabs = NodeTabContainer.get_children()[tab]
	var tab_children: Array = selected_tab_node.get_node("ScrollContainer/Margin/VBox").get_children()
	var tab_first_child = null
	
	
	if tab_children.size() > 0:
		
		
		tab_first_child = tab_children[0]
		
		
		if tab_first_child is HBoxContainer:
			
			
			tab_first_child = tab_first_child.get_children()[1]
		
		
		if tab_first_child is GridContainer:
			tab_first_child = tab_first_child.get_children()[0]
		
		tab_first_child.grab_focus()
		yield(get_tree(), "idle_frame")
		selected_tab_node.get_node("ScrollContainer").ensure_control_visible(tab_first_child)

func _on_AudioHSlider_value_changed(value: float, key: String) -> void :

	if $Timer.get_time_left() != 0:
		return
	
	Config.set_value("audio", key, value)
	get_node("Margin/TabContainer/AUDIO/ScrollContainer/Margin/VBox/HBox_%s/LblNum" % [key]).text = String(int(value)).pad_zeros(0)
	Audio.play_sfx("ui_changed_value")


func _on_Btn_remap_started() -> void :
	_can_change_tabs = false
	$ColorRect.visible = true



func _on_Btn_remap_closed() -> void :
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	_can_change_tabs = true
	
	$ColorRect.visible = false
	
	
	_ui_btns_have_conflict()




func _ui_btns_have_conflict() -> bool:
	var code_accept_gamepad = Config.get_value("gamepad", "ui_accept", 0)
	var code_cancel_gamepad = Config.get_value("gamepad", "ui_cancel", 0)
	var code_accept_keyboard = Config.get_value("keyboard", "ui_accept", 0)
	var code_cancel_keyboard = Config.get_value("keyboard", "ui_cancel", 0)
	
	var code_focus_next_gamepad = Config.get_value("gamepad", "ui_focus_next", 0)
	var code_ui_focus_prev_gamepad = Config.get_value("gamepad", "ui_focus_prev", 0)
	var code_focus_next_keyboard = Config.get_value("keyboard", "ui_focus_next", 0)
	var code_ui_focus_prev_keyboard = Config.get_value("keyboard", "ui_focus_prev", 0)

	if code_accept_gamepad == code_cancel_gamepad:
		Audio.play_sfx("ui_incorrect")
		Notification.show_notif(
			"%s (%s)" % [tr("ACCEPT_CANCEL_CONFLICT"), tr("GAMEPAD")]
		)
		return true
	elif code_accept_keyboard == code_cancel_keyboard:
		Audio.play_sfx("ui_incorrect")
		Notification.show_notif(
			"%s (%s)" % [tr("ACCEPT_CANCEL_CONFLICT"), tr("KEYBOARD")]
		)
		return true
	elif code_focus_next_gamepad == code_ui_focus_prev_gamepad:
		Audio.play_sfx("ui_incorrect")
		Notification.show_notif(
			"%s (%s)" % [tr("FOCUS_BTN_CONFLICT"), tr("GAMEPAD")]
		)
		return true
	elif code_focus_next_keyboard == code_ui_focus_prev_keyboard:
		Audio.play_sfx("ui_incorrect")
		Notification.show_notif(
			"%s (%s)" % [tr("FOCUS_BTN_CONFLICT"), tr("KEYBOARD")]
		)
		return true
	
	else:
		return false




func _on_BtnMainMenu_pressed() -> void :
	if _ui_btns_have_conflict() == true:
		return
	Audio.play_sfx("ui_cancel")
	SceneChanger.change_scene("res://src/screens/main_menu.tscn")


func _on_BtnCustomIconsBtns_pressed() -> void :
	if _ui_btns_have_conflict() == true:
		return
	Audio.play_sfx("ui_success")
	SceneChanger.change_scene("res://src/screens/options_edit_gamepad_icons.tscn")

func _on_BtnGmpdMapping_pressed() -> void :
	if _ui_btns_have_conflict() == true:
		return
	Audio.play_sfx("ui_success")
	SceneChanger.change_scene("res://src/screens/calibrate_gamepad.tscn")


func _on_BtnResetGamepadConf_pressed() -> void :
	Notification.show_notif(tr("CONF_BY_DEFAULT_DONE"))
	Audio.play_sfx("ui_success")
	
	
	
	Config.set_value("gamepad", "vibration", true)
	Config.set_value("gamepad", "joystick_enabled", true)

	
	for act_name in InputMap.get_actions():
		for act_ev in InputMap.get_action_list(act_name):
			if act_ev is InputEventJoypadButton or act_ev is InputEventJoypadMotion:
				InputMap.action_erase_event(act_name, act_ev)

	
	Config.set_value("gamepad", "attack", "x")
	Config.set_value("gamepad", "backdash", "leftshoulder")
	Config.set_value("gamepad", "circuit", "rightshoulder")
	Config.set_value("gamepad", "jump", "a")
	Config.set_value("gamepad", "quickmenu", "b")
	Config.set_value("gamepad", "ui_down", "dpdown")
	Config.set_value("gamepad", "ui_up", "dpup")
	Config.set_value("gamepad", "ui_left", "dpleft")
	Config.set_value("gamepad", "ui_right", "dpright")
	Config.set_value("gamepad", "ui_focus_next", "rightshoulder")
	Config.set_value("gamepad", "ui_focus_prev", "leftshoulder")
	Config.set_value("gamepad", "ui_start", "start")
	Config.set_value("gamepad", "ui_select", "back")
	
	
	
	if Features.has("switch"):
		Config.set_value("gamepad", "ui_accept", "b")
		Config.set_value("gamepad", "ui_cancel", "a")
	else:
		Config.set_value("gamepad", "ui_accept", "a")
		Config.set_value("gamepad", "ui_cancel", "b")
		

	yield(get_tree(), "idle_frame")
	Gamepad.refresh_mapping_controller()

func _on_BtnResetKeyboardConf_pressed() -> void :
	Notification.show_notif(tr("CONF_BY_DEFAULT_DONE"))
	Audio.play_sfx("ui_success")
	
	
	
	Config.set_value("keyboard", "ui_select", KEY_SHIFT)
	Config.set_value("keyboard", "ui_focus_next", KEY_SPACE)
	Config.set_value("keyboard", "ui_accept", KEY_X)
	Config.set_value("keyboard", "ui_start", KEY_ENTER)
	Config.set_value("keyboard", "ui_left", KEY_LEFT)
	Config.set_value("keyboard", "ui_cancel", KEY_C)
	Config.set_value("keyboard", "ui_up", KEY_UP)
	Config.set_value("keyboard", "ui_right", KEY_RIGHT)
	Config.set_value("keyboard", "ui_focus_prev", KEY_Z)
	Config.set_value("keyboard", "ui_down", KEY_DOWN)
	Config.set_value("keyboard", "jump", KEY_X)
	Config.set_value("keyboard", "attack", KEY_C)
	Config.set_value("keyboard", "circuit", KEY_SPACE)
	Config.set_value("keyboard", "backdash", KEY_Z)
	Config.set_value("keyboard", "quickmenu", KEY_F)
	
	

















func _on_BtnVisualMode_value_changed(_btn_name, _is_bool, value, _section, _key) -> void :
	
	if Features.has("pc") == false:
		return
	
	if value == "fullscreen":
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnResolution.visible = false
	else:
		$Margin / TabContainer / VIDEO / ScrollContainer / Margin / VBox / BtnResolution.visible = true


func _on_BtnEditTouchButtons_pressed() -> void :
	if _ui_btns_have_conflict() == true:
		return
	Audio.play_sfx("ui_success")
	SceneChanger.change_scene("res://src/ui_elements/virtual_gamepad.tscn")



func _on_GamepadConnection(connected: bool) -> void :
	var vpad_visible: bool = Config.get_value(
		"touch_screen_btn", "visible", false
	)
	if vpad_visible == true:
		NodeTabContainer.set_tab_disabled(
			3, not connected
		)


func _on_BtnDifficultyOptions_pressed() -> void :
	if _ui_btns_have_conflict() == true:
		return
	Audio.play_sfx("ui_accept")
	SceneChanger.change_scene("res://src/screens/dificulty_options.tscn")


func _on_BtnLang_value_changed(_btn_name, _is_bool, value, _section, _key) -> void :
	







	if value in ["es", "en", "pt_BR"]:
		get_node("%LblLangNotice").visible = false
		get_node("%HSeparatorLang").visible = false
	else:
		get_node("%LblLangNotice").visible = true
		get_node("%HSeparatorLang").visible = true










func _on_BtnCloseFanmadeLangNotif_pressed() -> void :
	get_node("%PopupAboutFanmadeTranslation").hide()


func _on_PopupAboutFanmadeTranslation_popup_hide() -> void :
	get_node("%BtnLang").grab_focus()
	Audio.play_sfx("ui_cancel")
	_can_change_tabs = true


func _on_BtnKnowMoreAboutFanmadeTranslation_pressed() -> void :
	Audio.play_sfx("ui_accept")
	OS.shell_open(
		"https://dannygaray60.itch.io/toziuha-night-order-of-the-alchemists/devlog/526277/fan-translations-open-for-toziuha-night-oota"
	)


func _on_BtnChangeScheme_pressed() -> void :
	Audio.play_sfx("ui_accept")
	SceneChanger.change_scene("res://src/screens/change_scheme_helper.tscn")
