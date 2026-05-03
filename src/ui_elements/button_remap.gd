extends Button

signal remap_started
signal remap_updated
signal remap_canceled

export (String, "keyboard", "gamepad") var type_input = "keyboard"
export (String, 
	"ui_start", 
	"ui_select", 
	"ui_accept", 
	"ui_cancel", 
	"ui_up", 
	"ui_down", 
	"ui_left", 
	"ui_right", 
	"ui_focus_prev", 
	"ui_focus_next", 
	"jump", 
	"quickmenu", 
	"attack", 
	"circuit", 
	"backdash"
) var action_input = "ui_start"

func _ready() -> void :
	
	
	Config.connect("value_changed", self, "_on_Config_updated")
	
	_update_text()
	
	$HelperIconBtn.show_specific_icon = type_input
	$HelperIconBtn.action = action_input
	$HelperIconBtn.update_icon()


func _input(event: InputEvent) -> void :
	
	
	
	if (
		event is InputEventScreenTouch
		
		
		
	):
		return
	
	
	if event.is_pressed() and disabled == true:
		
		
		if event is InputEventKey and event.as_text() == "Escape":
			_end_remap(true)
		
		
		
		elif (
			type_input == "gamepad"
			and (
				event is InputEventJoypadButton
				or event is InputEventJoypadMotion
			)
		) or (
			type_input == "keyboard"
			and (
				event is InputEventKey
				or event is InputEventMouseButton
			)
		):
			_apply_remap(event)
		
		
		else:
			Audio.play_sfx("ui_incorrect")
			Notification.show_notif(tr("INPUT_DEVICE_INCORRECT"))

func _update_text() -> void :
	text = tr("ACTION_" + action_input.to_upper())
	
	var message_complement: String
	
	if OS.get_name() == "Android":
		message_complement = tr("PRESS_BACK_ANDROID")
	else:
		message_complement = tr("PRESS_ESCAPE")
	
	if type_input == "keyboard":
		$LblMsg.text = tr("PRESS_NEW_KEY") % message_complement
	else:
		$LblMsg.text = tr("PRESS_NEW_BTN") % message_complement
	
	$LblMsg.visible = false

func _set_neighbour(neighbour: NodePath) -> void :
	focus_neighbour_left = neighbour
	focus_neighbour_top = neighbour
	focus_neighbour_right = neighbour
	focus_neighbour_bottom = neighbour
	focus_next = neighbour
	focus_previous = neighbour

func _apply_remap(new_event: InputEvent) -> void :

	if type_input == "gamepad":
		var code: String
		var btn_names_list: Array = Config.get_section_keys("controller")
		
		if new_event is InputEventJoypadButton:
			code = "b" + str(new_event.button_index)
		elif new_event is InputEventJoypadMotion:
			code = "a" + str(new_event.axis)
		
		for n in btn_names_list:
			if (
				Config.get_value("controller", n, "b0") == code
				and n != "leftx" and n != "lefty"
				and n != "rightx" and n != "righty"
			):
				
				
				for act in InputMap.get_action_list(action_input):
					if act is InputEventJoypadButton or act is InputEventJoypadMotion:
						InputMap.action_erase_event(action_input, act)
				
				Config.set_value("gamepad", action_input, n)
				break
		
		yield(get_tree(), "idle_frame")
		Gamepad.refresh_mapping_controller()
















	
	
	





























	if type_input == "keyboard":
		_update_godot_event(new_event)
		
	
	
	
	
	

	$TimerAppliedRemap.start()
	Audio.play_sfx("ui_success")
	emit_signal("remap_updated")
	_end_remap()

func _update_godot_event(new_event: InputEvent, action_in: String = action_input) -> void :
	
	for ev in InputMap.get_action_list(action_in):
		
		
		if (
			type_input == "keyboard" and ev is InputEventKey
			or type_input == "keyboard" and ev is InputEventMouseButton
			
			
		):
			
			InputMap.action_erase_event(action_in, ev)
			
			InputMap.action_add_event(action_in, new_event)
			
			if type_input == "keyboard" and new_event is InputEventKey:
				Config.set_value(
					"keyboard", action_in, new_event.get_scancode_with_modifiers()
				)
			
			
			elif type_input == "keyboard" and new_event is InputEventMouseButton:
				Config.set_value(
					"keyboard", action_in, new_event.button_index * - 1
				)




			break
	

func _end_remap(canceled: bool = false) -> void :
	
	
	if disabled == true:
		
		if canceled == true:
			Audio.play_sfx("ui_cancel")
			emit_signal("remap_canceled")
		
		$LblMsg.visible = false
		$HelperIconBtn.visible = true
		_set_neighbour("")
		
		disabled = false

func _on_ButtonRemap_pressed() -> void :
	
	if $TimerAppliedRemap.get_time_left() == 0:
		Audio.play_sfx("ui_accept")
		emit_signal("remap_started")
		disabled = true
		$LblMsg.visible = true
		$HelperIconBtn.visible = false
		_set_neighbour(self.get_path())

func _on_Config_updated(_section: String, _key, _value) -> void :
	
	
	
	
	_update_text()
	$HelperIconBtn.update_icon()
	


func _notification(what):
	if (
		what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST
		and OS.get_name() == "Android"
	):
		_end_remap(true)
