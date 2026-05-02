extends Node

export (Array, NodePath) var objs: = []

func _ready() -> void :
	
	
	Gamepad.connect(
		"gamepad_connection_changed", self, 
		"_on_GamepadConnection"
	)
	
	set_visible_objs()

func set_visible_objs() -> void :
	
	var gamepad_connected: bool = Gamepad.is_controller_connected()
	var vpad_visible: bool = Config.get_value(
		"touch_screen_btn", "visible", false
	)
	var vpad_always_visible: bool = Config.get_value(
		"touch_screen_btn", "always_visible", false
	)

	if vpad_visible == false:
		return
	
	for n in objs:
		if gamepad_connected == true and vpad_always_visible == false:
			get_node(n).visible = true
		else:
			get_node(n).visible = false

func _on_GamepadConnection(_connected: bool) -> void :
	set_visible_objs()
