extends Control

func _ready() -> void :
	if Features.has("mobile") == false:
		$HBoxContainer / BtnYes.text = "%s: %s [Y]" % [tr("YES"), tr("PRESS")]
		$HBoxContainer / BtnNo.text = "%s: %s [N]" % [tr("YES"), tr("PRESS")]
	
	Config.set_value("misc", "firstrun", true)
	
	for devnum in Input.get_connected_joypads():
		get_node("%LblDevicesConnected").text += Input.get_joy_name(devnum) + ","
	
func _input(event: InputEvent) -> void :
	
	if event is InputEventKey and event.is_pressed() and event.is_echo() == false:
		
		if event.scancode == KEY_Y:
			_on_BtnYes_pressed()
		elif event.scancode == KEY_N:
			_on_BtnNo_pressed()

func _on_BtnYes_pressed() -> void :
	Audio.play_sfx("ui_accept")
	SceneChanger.change_scene("res://src/screens/calibrate_gamepad.tscn")

func _on_BtnNo_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	SceneChanger.change_scene("res://src/screens/title_screen.tscn")
