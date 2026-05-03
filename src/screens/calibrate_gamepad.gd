extends Control

var device_current: int = - 1
var gamepad_guid: String
var gamepad_name: String

var current_phase: int = 0

var names_btn_list: Array = [
	"dpup", "dpright", "dpdown", "dpleft", 
	"a", "b", "x", "y", 
	"start", "back", 
	"leftshoulder", "rightshoulder", "lefttrigger", "righttrigger", 
	"leftx", "lefty", "leftstick", 
	"rightx", "righty", "rightstick"
]

var events_list: Dictionary


var _codes_added: Array



var _ready_to_detect: bool

onready var TimerCoolDown = $TimerCooldown

var mouse_mode: int

func _ready() -> void :
	
	
	
	
	if Features.has("mobile"):
		$VBoxContainer / LabelToReturn.visible = false
	else:
		$VBoxContainer / BtnReturn.visible = false
		$BtnStart.text = tr("PRESSSPACETOSTART")
		$HBxInRemap / BtnCancel.text = tr("ACTION_UI_CANCEL") + " [X]"
		$HBxInRemap / BtnSkip.text = tr("SKIP") + " [N]"
	
	$HBxInRemap.visible = false
	$GamepadCtrl.visible = false
	$LblMsgRestart.visible = false
	
	Gamepad.connect(
		"gamepad_connection_changed", self, 
		"_on_gamepad_connection_changed"
	)
	
	refresh_gamepads_list()

func refresh_gamepads_list() -> void :
	device_current = - 1
	$OptionButton.clear()
	$OptionButton.add_item("SELECTADEVICE", - 2)
	var device_name: String = "Unknown"
	for id in Gamepad.connected_devices:
		device_name = Input.get_joy_name(id)
		$OptionButton.add_item(device_name, id)

	$BtnStart.disabled = true
	
	if Gamepad.connected_devices.empty() == false:
		$OptionButton.select(1)
		_on_OptionButton_item_selected(1)

func start_receive_input() -> void :
	
	if $GamepadCtrl.visible == false:
		return
	
	$GamepadCtrl / AnimationPlayer.play("tin")
	$GamepadCtrl / Btn.frame = current_phase
	current_phase = 0

func receive_input(ev: InputEvent) -> void :

	if $GamepadCtrl.visible == false or _ready_to_detect == false:
		return
	
	
	var code_string: String
	
	if ev is InputEventJoypadButton:
		code_string = "b" + str(ev.button_index)
	elif ev is InputEventJoypadMotion:
		code_string = "a" + str(ev.axis)
	
	
	if code_string in _codes_added:
		Audio.play_sfx("ui_incorrect")
		Notification.show_notif("THEBUTTONALREADYADDED")
		return
	
	_ready_to_detect = false
	
	_codes_added.append(code_string)
	events_list[names_btn_list[current_phase]] = ev
	_go_next_phase()

func _go_next_phase() -> void :
	Audio.play_sfx("ui_btn_calibrate_pressed")
	current_phase += 1
	$GamepadCtrl / AnimationPlayer.play("tin")
	$GamepadCtrl / Btn.frame = current_phase
	
	if current_phase > names_btn_list.size() - 1:
		_on_end_calibration()
		return
	
	_ready_to_detect = true

func _input(event: InputEvent) -> void :

	
	if (
		event is InputEventKey
		and event.is_pressed()
		and $GamepadCtrl.visible == false
		and event.is_echo() == false
	):
		
		if event.scancode == KEY_ESCAPE:
			_on_BtnReturn_pressed()
		
		if event.scancode == KEY_SPACE:
			if $BtnStart.disabled == false:
				_on_BtnStart_pressed()
			else:
				Audio.play_sfx("ui_incorrect")
	
	if (
		event is InputEventKey
		and event.is_pressed()
		and $HBxInRemap.visible == true
		and event.is_echo() == false
	):
		
		if event.scancode == KEY_X:
			_on_BtnCancel_pressed()
		elif event.scancode == KEY_N:
			_on_BtnSkip_pressed()

	if $GamepadCtrl.visible == true and (
		(event is InputEventJoypadButton)
		or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.9)
	) and event.is_pressed() and _ready_to_detect == true and TimerCoolDown.is_stopped():
		if event.device == device_current:
			TimerCoolDown.start()
			get_tree().set_input_as_handled()
			receive_input(event)

func _on_start_calibration() -> void :
	
	gamepad_guid = Input.get_joy_guid(device_current)
	gamepad_name = Input.get_joy_name(device_current)

	
	
	Input.remove_joy_mapping(gamepad_guid)

	_ready_to_detect = true
	_codes_added = []
	events_list = {}
	$LblMsgRestart.visible = false
	
	$OptionButton.visible = false
	$VBoxContainer.visible = false
	$BtnStart.visible = false
	$HBxInRemap.visible = true
	Audio.play_sfx("ui_accept")
	$GamepadCtrl.visible = true
	start_receive_input()

func _on_end_calibration() -> void :
	
	var mapping_string: String
	
	var i = 0
	
	
	mapping_string = "%s,%s," % [gamepad_guid, gamepad_name]
	
	for btn_name in events_list.keys():
		
		var ev_selected: InputEvent = events_list[btn_name]
		var ev_index: int
		
		if ev_selected is InputEventJoypadButton:
			ev_index = ev_selected.button_index
			mapping_string += "%s:b%s," % [btn_name, ev_index]
			
		elif ev_selected is InputEventJoypadMotion:
			ev_index = ev_selected.axis
			mapping_string += "%s:a%s," % [btn_name, ev_index]
			

		i += 1
	
	
	mapping_string += "platform:%s," % [OS.get_name()]
	
	if events_list.keys().size() > 0:
		Config.set_value("controller", "mapping_string", mapping_string)
	
	Gamepad.refresh_mapping_controller()

	Audio.play_sfx("ui_accept")
	Notification.show_notif("CALIBRATIONFINISHED")
	
	if Config.get_value("misc", "controller_mapped_first_time", false) == false:
		
		
		if Features.has("mobile"):
			Config.set_value("touch_screen_btn", "always_visible", false)
		
		Config.set_value("misc", "controller_mapped_first_time", true)
		SceneChanger.change_scene("res://src/screens/title_screen.tscn")
		return
	
	refresh_gamepads_list()
	
	$OptionButton.visible = true
	$VBoxContainer.visible = true
	$BtnStart.visible = true
	$HBxInRemap.visible = false
	$GamepadCtrl.visible = false
	current_phase = 0
	device_current = $OptionButton.get_item_id($OptionButton.selected)

func _on_BtnStart_pressed() -> void :
	_on_start_calibration()


func _on_BtnCancel_pressed() -> void :
	$OptionButton.visible = true
	
	$VBoxContainer.visible = true
	$BtnStart.visible = true
	$HBxInRemap.visible = false
	Audio.play_sfx("ui_cancel")
	$GamepadCtrl.visible = false
	current_phase = 0


func _on_BtnSkip_pressed() -> void :
	_go_next_phase()


func _on_BtnReturn_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	
	if Config.get_value("misc", "controller_mapped_first_time", false) == false:
		Config.set_value("misc", "controller_mapped_first_time", true)
		SceneChanger.change_scene("res://src/screens/title_screen.tscn")
	else:
		SceneChanger.change_scene("res://src/screens/options.tscn")


func _on_OptionButton_item_selected(index: int) -> void :
	var item_id: int = $OptionButton.get_item_id(index)
	if item_id < 0:
		$BtnStart.disabled = true
	else:
		$BtnStart.disabled = false
	device_current = item_id

func _on_gamepad_connection_changed(_device_connected: bool) -> void :
	if _ready_to_detect == true:
		return
	refresh_gamepads_list()


func _on_BtnResetDefault_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	
	
	if Config.get_value("controller", "mapping_string", "") != "":
		var guid_split: Array = Config.get_value("controller", "mapping_string", "").split(",", false, 1)
		if guid_split.empty() == false:
			Input.remove_joy_mapping(guid_split[0])
		Config.set_value("controller", "mapping_string", "")
		$LblMsgRestart.visible = true
	
	Notification.show_notif("CONF_BY_DEFAULT_DONE")
	refresh_gamepads_list()


func _on_CalibrateGamepad_tree_exiting() -> void :
	
	pass
