extends Node









const BUFFER_WINDOW: int = 150

var keyboard_timestamps: Dictionary
var joypad_timestamps: Dictionary
var touchpad_timestamps: Dictionary


func _ready() -> void :
	pause_mode = Node.PAUSE_MODE_PROCESS
	clear_timestamps()


func _input(event: InputEvent) -> void :

	if event is InputEventKey:
		if not event.pressed or event.is_echo():
			return
		var scancode: int = event.scancode
		keyboard_timestamps[scancode] = Time.get_ticks_msec()
	
	elif event is InputEventJoypadButton:
		if not event.pressed or event.is_echo():
			return
		var button_index: int = event.button_index
		joypad_timestamps[button_index] = Time.get_ticks_msec()
	
	elif event is InputEventMouseButton:
		if not event.pressed or event.is_echo():
			return
		var button_index: int = event.button_index * - 1
		joypad_timestamps[button_index] = Time.get_ticks_msec()

	elif event is InputEventAction:
		if not event.pressed or event.is_echo():
			return
		var button_action: String = event.action
		touchpad_timestamps[button_action] = Time.get_ticks_msec()

func clear_timestamps() -> void :
	
	keyboard_timestamps = {}
	joypad_timestamps = {}
	touchpad_timestamps = {}


func is_action_press_buffered(action: String) -> bool:
	
	
	for event in InputMap.get_action_list(action):
		
		if event is InputEventKey:
			var scancode: int = event.scancode
			if keyboard_timestamps.has(scancode):
				if Time.get_ticks_msec() - keyboard_timestamps[scancode] <= BUFFER_WINDOW:
					
					_invalidate_action(action)
					return true
		
		elif event is InputEventJoypadButton:
			var button_index: int = event.button_index
			if joypad_timestamps.has(button_index):
				if Time.get_ticks_msec() - joypad_timestamps[button_index] <= BUFFER_WINDOW:
					_invalidate_action(action)
					return true

		elif event is InputEventMouseButton:
			var button_index: int = event.button_index * - 1
			if joypad_timestamps.has(button_index):
				if Time.get_ticks_msec() - joypad_timestamps[button_index] <= BUFFER_WINDOW:
					_invalidate_action(action)
					return true
		
	if touchpad_timestamps.has(action):
		if Time.get_ticks_msec() - touchpad_timestamps[action] <= BUFFER_WINDOW:
			_invalidate_action(action)
			return true
	
	return false




func _invalidate_action(action: String) -> void :
	for event in InputMap.get_action_list(action):
		
		if event is InputEventKey:
			var scancode: int = event.scancode
			if keyboard_timestamps.has(scancode):
				keyboard_timestamps[scancode] = 0
		
		elif event is InputEventJoypadButton:
			var button_index: int = event.button_index
			if joypad_timestamps.has(button_index):
				joypad_timestamps[button_index] = 0

	if touchpad_timestamps.has(action):
		touchpad_timestamps[action] = 0
