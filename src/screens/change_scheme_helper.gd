extends Control

var previous_scheme: Dictionary = {
	"a": 0, 
	"b": 0, 
	"back": 0, 
	"dpdown": 0, 
	"dpleft": 0, 
	"dpright": 0, 
	"dpup": 0, 
	"leftshoulder": 0, 
	"leftstick": 0, 
	"lefttrigger": 0, 
	"rightshoulder": 0, 
	"rightstick": 0, 
	"righttrigger": 0, 
	"start": 0, 
	"x": 0, 
	"y": 0
}

func _ready() -> void :
	$VBoxContainer / BtnScheme.grab_focus()
	$VBoxContainer / BtnScheme._update_value(false)
	update_icons(previous_scheme)

func update_icons(scheme: Dictionary) -> void :
	
	for n in previous_scheme.keys():
		previous_scheme[n] = Config.get_value("controller_helper", n, "start")
	
	for n in $ControlGamepad / GamepadTester.get_children():
		n.frame = scheme[n.name]

func _on_BtnScheme_value_changed(_btn_name, _is_bool, value, _section, _key) -> void :
	match value:
		"xbox":
			update_icons(Config.xb_scheme)
		"xbox2":
			update_icons(Config.xb2_scheme)
		"ps":
			update_icons(Config.ps5_scheme)
		"psb":
			update_icons(Config.ps4_scheme)
		"psc":
			update_icons(Config.ps2_scheme)
		"switch":
			update_icons(Config.sw_scheme)
		"deck":
			update_icons(Config.deck_scheme)
		"generic":
			update_icons(Config.generic_scheme)
		_:
			update_icons(previous_scheme)

func _on_BtnSave_pressed() -> void :
	Audio.play_sfx("ui_success")
	Notification.show_notif("CHANGESSAVED")
	for n in $ControlGamepad / GamepadTester.get_children():
		Config.set_value("controller_helper", n.name, n.frame)

func _on_BtnReturn_pressed() -> void :
	Audio.play_sfx("ui_accept")
	SceneChanger.change_scene("res://src/screens/options.tscn")
