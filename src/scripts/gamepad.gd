extends Node

signal gamepad_connection_changed(device_connected)

var connected_devices: Array

const INPUT_BLACKLIST: = [
	"uinput-fpc", 
	"uinput-goodix", 
	"uinput-synaptics", 
	"uinput-elan", 
	"uinput-vfs", 
	"uinput-atrus", 
]

const INPUT_WHITELIST: = [
	"XInput Gamepad", "Xbox Series Controller", "Xbox 360 Controller", "Xbox One Controller", 
	"Sony DualSense", "PS5 Controller", "PS4 Controller", "Nacon Revolution Unlimited Pro Controller", 
	"Switch", "Joy-Con (L)", "Joy-Con (R)"
]




func _ready() -> void :
	
	refresh_connected_devices()

	
	Input.connect("joy_connection_changed", self, "_on_Gamepad_connection_changed")
	
	
	
	if is_controller_connected() == true:
		Config.set_value("gameplay", "icons_buttons", "gamepad")
	else:
		Config.set_value("gameplay", "icons_buttons", "keyboard")
		
	refresh_mapping_controller()

func is_controller_connected() -> bool:
	if connected_devices.size() > 0:
		return true
	else:
		return false

func refresh_connected_devices() -> void :
	connected_devices = Input.get_connected_joypads()
	for devid in connected_devices:
		var device_name: String = Input.get_joy_name(devid)
		var device_name_lower: String = device_name.to_lower()
		if device_name in INPUT_WHITELIST:
			print("device detected (whitelist): " + device_name)
		elif (
			device_name in INPUT_BLACKLIST
			or "keyboard" in device_name_lower
			or "mouse" in device_name_lower
			or "sensor" in device_name_lower
			or "device" in device_name_lower
		):
			connected_devices.erase(devid)
			print("device invalid, deleted: " + device_name)
		else:
			print("device detected unknown: " + device_name)
	

func refresh_mapping_controller() -> void :

	
	
	for k in Config.get_section_keys("gamepad"):
		
		if InputMap.has_action(k):
			
			InputMap.action_erase_event(k, InputEventJoypadButton.new())
			InputMap.action_erase_event(k, InputEventJoypadMotion.new())
			
			var ev: InputEvent
			
			var code: String = Config.get_value(
				"controller", Config.get_value("gamepad", k, "start"), "b11"
			)
			if code.begins_with("b"):
				ev = InputEventJoypadButton.new()
				ev.button_index = int(code.trim_prefix("b"))
			elif code.begins_with("a"):
				ev = InputEventJoypadMotion.new()
				ev.axis = int(code.trim_prefix("a"))
			ev.device = - 1
			InputMap.action_add_event(k, ev)

	
	for k in [
		"ui_joy_up", "ui_joy_left", "ui_joy_right", "ui_joy_down", 
		"r_joy_up", "r_joy_left", "r_joy_right", "r_joy_down"
	]:
		if InputMap.has_action(k):
			
			
			InputMap.action_erase_event(k, InputEventJoypadButton.new())
			InputMap.action_erase_event(k, InputEventJoypadMotion.new())
			
			var ev: InputEvent
			
			
			var code: String
			
			if k.ends_with("up") or k.ends_with("down"):
				if k.begins_with("ui_"):
					code = Config.get_value("controller", "lefty", "a0")
				else:
					code = Config.get_value("controller", "righty", "a0")

			
			elif k.ends_with("left") or k.ends_with("right"):
				if k.begins_with("ui_"):
					code = Config.get_value("controller", "leftx", "a0")
				else:
					code = Config.get_value("controller", "rightx", "a0")

			if code.begins_with("b"):
				ev = InputEventJoypadButton.new()
				ev.button_index = int(code.trim_prefix("b"))
			elif code.begins_with("a"):
				ev = InputEventJoypadMotion.new()
				ev.axis = int(code.trim_prefix("a"))
				ev.axis_value = 1
				if k.ends_with("left") or k.ends_with("up"):
					ev.axis_value = ev.axis_value * - 1
			
			ev.device = - 1
			
			InputMap.action_add_event(k, ev)

	
	if Config.get_value("controller", "mapping_string", "") != "":
		var guid_split: Array = Config.get_value("controller", "mapping_string", "").split(",", false, 1)
		if guid_split.empty() == false:
			Input.remove_joy_mapping(guid_split[0])
		Input.add_joy_mapping(
			Config.get_value("controller", "mapping_string", ""), true
		)


func _process(_delta: float) -> void :
	
	
	
	
	if Config.joystick_enabled == true:

		if Input.is_action_just_pressed("ui_joy_up"):
			Input.action_press("ui_up")
		elif Input.is_action_just_released("ui_joy_up"):
			Input.action_release("ui_up")
		
		if Input.is_action_just_pressed("ui_joy_down"):
			Input.action_press("ui_down")
		elif Input.is_action_just_released("ui_joy_down"):
			Input.action_release("ui_down")

		if Input.is_action_just_pressed("ui_joy_left"):
			Input.action_press("ui_left")
		elif Input.is_action_just_released("ui_joy_left"):
			Input.action_release("ui_left")

		if Input.is_action_just_pressed("ui_joy_right"):
			Input.action_press("ui_right")
		elif Input.is_action_just_released("ui_joy_right"):
			Input.action_release("ui_right")

func start_vibration(
	device: int, weak_magnitude: float, 
	strong_magnitude: float, duration: float = 0
) -> void :
	if Config.gamepad_vibration:
		
		
		
		if (
			OS.get_name() in ["Android", "iOS"]
			and is_controller_connected() == false
		):
			Input.vibrate_handheld(int(duration / 1000))
		else:
			Input.start_joy_vibration(device, weak_magnitude, strong_magnitude, duration)

func _on_Gamepad_connection_changed(_device: int, connected: bool):
	var firststart: bool = false
	
	
	if OS.get_ticks_msec() < 5000:
		firststart = true
	
	if connected:
		Config.set_value("gameplay", "icons_buttons", "gamepad")
		if firststart == false:
			Notification.show_notif(tr("GAMEPAD_CONNECTED"))
			Audio.play_sfx("ui_device_plug")
	else:
		Config.set_value("gameplay", "icons_buttons", "keyboard")
		if firststart == false:
			Notification.show_notif(tr("GAMEPAD_DISCONNECTED"))
			Audio.play_sfx("ui_device_unplug")
	refresh_connected_devices()
	emit_signal("gamepad_connection_changed", connected)
