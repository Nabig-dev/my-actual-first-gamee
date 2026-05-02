extends Control

var step: int = 0

func _ready() -> void :
	get_node("%BlackRectScr").visible = true
	
	if Gamepad.is_controller_connected() == true:
		step = 2
		next_step()
		return
	get_node("%BlackRectScr").visible = false
	get_node("%Step0").visible = true
	get_node("%Step1").visible = false

func _input(event: InputEvent) -> void :
	
	
	if (
		event is InputEventKey
		and event.is_pressed()
		and event.is_echo() == false
	):
		if step == 0:
			if event.scancode == KEY_W:
				
				Config.set_value("keyboard", "ui_select", KEY_M)
				Config.set_value("keyboard", "ui_focus_next", KEY_E)
				Config.set_value("keyboard", "ui_accept", KEY_SPACE)
				Config.set_value("keyboard", "ui_start", KEY_TAB)
				Config.set_value("keyboard", "ui_left", KEY_A)
				Config.set_value("keyboard", "ui_cancel", BUTTON_RIGHT * - 1)
				Config.set_value("keyboard", "ui_up", KEY_W)
				Config.set_value("keyboard", "ui_right", KEY_D)
				Config.set_value("keyboard", "ui_focus_prev", KEY_Q)
				Config.set_value("keyboard", "ui_down", KEY_S)
				Config.set_value("keyboard", "jump", KEY_SPACE)
				Config.set_value("keyboard", "attack", BUTTON_LEFT * - 1)
				Config.set_value("keyboard", "circuit", BUTTON_RIGHT * - 1)
				Config.set_value("keyboard", "backdash", KEY_SHIFT)
				Config.set_value("keyboard", "quickmenu", KEY_F)
				next_step()
				
			elif event.scancode == KEY_ENTER:
				
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
				next_step()
	
		if step == 1:
			if event.scancode == KEY_A:
				Config.set_value("video", "filter", "none")
				next_step()
			elif event.scancode == KEY_B:
				Config.set_value("video", "filter", "crt_curved")
				next_step()
			elif event.scancode == KEY_C:
				Config.set_value("video", "filter", "crt_simple")
				next_step()
			

func next_step() -> void :
	Audio.play_sfx("ui_btn_calibrate_pressed")
	step += 1
	
	match step:
		0:
			pass
		1:
			get_node("%Step0").visible = false
			get_node("%Step1").visible = true
		
		
		_:
			Config.set_value("misc", "firstrun", true)
			
			Audio.play_sfx("ui_success")
			
			
			Config.set_value("misc", "controller_mapped_first_time", true)
	
			
			SceneChanger.change_scene("res://src/screens/title_screen.tscn")
