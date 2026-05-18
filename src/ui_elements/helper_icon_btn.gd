extends Control

export (
	String, "no_hide", "visible", "modulate"
) var hide_method_touch = "no_hide"

export var animated = false
export (String, "automatic", "keyboard", "gamepad") var show_specific_icon = "automatic"
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
) var action = "ui_start"

export var show_custom_frame: int = - 1

onready var Lbl = $Texture / Label
onready var AnimPlayer = $AnimationPlayer

var font = Font

func _ready() -> void :

	
	Config.connect("value_changed", self, "_on_Config_updated")
	
	
	Gamepad.connect(
		"gamepad_connection_changed", self, 
		"_on_GamepadConnection"
	)
	
	hide_on_touch()
	
	
	Lbl.add_font_override("font", Lbl.get_font("font").duplicate())
	
	Lbl.visible = false
	if animated:
		AnimPlayer.play("press_anim")
	update_icon()

func update_icon() -> void :
	
	Lbl.visible = false
	var gamepad_icon: String = Config.icons_buttons
	
	if Features.has("switch") or Features.has("ps") or Features.has("xbox"):
		gamepad_icon = "gamepad"
	
	if show_specific_icon != "automatic":
		gamepad_icon = show_specific_icon
	
	
	if show_custom_frame >= 0:
		$Texture / Normal.frame = show_custom_frame
		$Texture / Pressed.frame = show_custom_frame
		Lbl.visible = false
	
	
	elif gamepad_icon == "gamepad":
		
		var bind_btn: String = Config.get_value("gamepad", action, "start")
		var icon: int = Config.get_value("controller_helper", bind_btn, 0)
		$Texture / Normal.frame = icon
		$Texture / Pressed.frame = icon
		Lbl.visible = false
		
	
	elif gamepad_icon == "keyboard":
		var vpad_visible: bool = Config.get_value(
			"touch_screen_btn", "visible", false
		)
		var vpad_always_visible: bool = Config.get_value(
			"touch_screen_btn", "always_visible", false
		)
		
		
		if vpad_visible == true or vpad_always_visible == true:
			var icon: int
			Lbl.visible = false
			
			match action:
				"ui_start":
					icon = 59
				"ui_select":
					icon = 61
				"ui_accept":
					icon = 0
				"ui_cancel":
					icon = 1
				"ui_up":
					icon = 63
				"ui_down":
					icon = 65
				"ui_left":
					icon = 62
				"ui_right":
					icon = 64
				"ui_focus_prev":
					icon = 40
				"ui_focus_next":
					icon = 41
				"jump":
					icon = 66
				"quickmenu":
					icon = 60
				"attack":
					icon = 70
				"circuit":
					icon = 68
				"backdash":
					icon = 67
				
			$Texture / Normal.frame = icon
			$Texture / Pressed.frame = icon
			return
		
		
		
		var event: InputEvent
		var txt_to_show: String
		
		for ev in InputMap.get_action_list(action):
			if (
				ev is InputEventKey
				or ev is InputEventMouseButton
			):
				event = ev
				break
		
		txt_to_show = event.as_text()
		
		
		
		if event is InputEventMouseButton:
			txt_to_show = "M" + str(event.button_index)
		
		
		match txt_to_show:
			"M1":
				$Texture / Normal.frame = 84
				$Texture / Pressed.frame = 84
			"M2":
				$Texture / Normal.frame = 85
				$Texture / Pressed.frame = 85
			"M3":
				$Texture / Normal.frame = 86
				$Texture / Pressed.frame = 86
			"M4":
				$Texture / Normal.frame = 82
				$Texture / Pressed.frame = 82
			"M5":
				$Texture / Normal.frame = 83
				$Texture / Pressed.frame = 83
			"Enter":
				$Texture / Normal.frame = 91
				$Texture / Pressed.frame = 91
			"Escape":
				$Texture / Normal.frame = 98
				$Texture / Pressed.frame = 98
			"Tab":
				$Texture / Normal.frame = 89
				$Texture / Pressed.frame = 89
			"Backspace":
				$Texture / Normal.frame = 90
				$Texture / Pressed.frame = 90
			"Left":
				$Texture / Normal.frame = 92
				$Texture / Pressed.frame = 92
			"Right":
				$Texture / Normal.frame = 94
				$Texture / Pressed.frame = 94
			"Up":
				$Texture / Normal.frame = 93
				$Texture / Pressed.frame = 93
			"Down":
				$Texture / Normal.frame = 95
				$Texture / Pressed.frame = 95
			"Shift":
				$Texture / Normal.frame = 88
				$Texture / Pressed.frame = 88
			"Control":
				$Texture / Normal.frame = 97
				$Texture / Pressed.frame = 97
			"Alt":
				$Texture / Normal.frame = 96
				$Texture / Pressed.frame = 96
			"Space":
				$Texture / Normal.frame = 87
				$Texture / Pressed.frame = 87
			
			_:

				
				if txt_to_show.length() < 3:
					Lbl.get_font("font").size = 11
				elif txt_to_show.length() <= 3:
					Lbl.get_font("font").size = 8
				else:
					Lbl.get_font("font").size = 4

				$Texture / Normal.frame = 99
				$Texture / Pressed.frame = 99
				
				Lbl.text = txt_to_show
				Lbl.visible = true
				

func hide_on_touch() -> void :
	var gamepad_connected: bool = Gamepad.is_controller_connected()
	var vpad_visible: bool = Config.get_value(
		"touch_screen_btn", "visible", false
	)
	var vpad_always_visible: bool = Config.get_value(
		"touch_screen_btn", "always_visible", false
	)
	
	if vpad_visible == false:
		return
	
	if gamepad_connected == true and vpad_always_visible == false:
		match hide_method_touch:
			"visible":
				visible = true
			"modulate":
				modulate.a = 1
	else:
		match hide_method_touch:
			"visible":
				visible = false
			"modulate":
				modulate.a = 0

func _on_Config_updated(section, key, _value) -> void :
	if (
		section == "helper_btn_icon"
		or (section == "gameplay" and key == "icons_buttons")
		or section in ["keyboard", "gamepad"]
	):
		update_icon()

func _on_GamepadConnection(_connected: bool) -> void :
	hide_on_touch()
