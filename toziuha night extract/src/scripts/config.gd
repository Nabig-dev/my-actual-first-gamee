extends Node



signal value_changed(section, key, value)

var Cnf = ConfigFile.new()

var CnfJson = preload("res://addons/json_config_file/json_conf.gd").new()



var joystick_enabled: bool

var vfx_level: int

var icons_buttons: String

var camera_shake: bool

var gamepad_vibration: bool


var default_virtualpad_positions: Dictionary = {
	"Start": Vector2(4, - 113), 
	"Select": Vector2(51, - 113), 
	"Dpad": Vector2(50, - 9), 
	"B": Vector2( - 17, - 104), 
	"A": Vector2( - 5, - 29), 
	"L": Vector2( - 40, - 54), 
	"X": Vector2( - 45, - 11), 
	"X2": Vector2( - 22.308, 8.462), 
	"R": Vector2( - 3, - 71), 
	"C": Vector2( - 102, 4), 
}


var xb_scheme: Dictionary = {
	"a": 0, 
	"b": 1, 
	"back": 18, 
	"dpdown": 65, 
	"dpleft": 62, 
	"dpright": 64, 
	"dpup": 63, 
	"leftshoulder": 6, 
	"leftstick": 44, 
	"lefttrigger": 8, 
	"rightshoulder": 7, 
	"rightstick": 45, 
	"righttrigger": 9, 
	"start": 19, 
	"x": 2, 
	"y": 3
}
var xb2_scheme: Dictionary = {
	"a": 14, 
	"b": 15, 
	"back": 18, 
	"dpdown": 65, 
	"dpleft": 62, 
	"dpright": 64, 
	"dpup": 63, 
	"leftshoulder": 20, 
	"leftstick": 44, 
	"lefttrigger": 22, 
	"rightshoulder": 21, 
	"rightstick": 45, 
	"righttrigger": 23, 
	"start": 19, 
	"x": 16, 
	"y": 17
}
var ps5_scheme: Dictionary = {
	"a": 10, 
	"b": 11, 
	"back": 54, 
	"dpdown": 39, 
	"dpleft": 36, 
	"dpright": 38, 
	"dpup": 37, 
	"leftshoulder": 32, 
	"leftstick": 47, 
	"lefttrigger": 34, 
	"rightshoulder": 33, 
	"rightstick": 46, 
	"righttrigger": 35, 
	"start": 55, 
	"x": 12, 
	"y": 13
}
var ps4_scheme: Dictionary = {
	"a": 24, 
	"b": 25, 
	"back": 29, 
	"dpdown": 39, 
	"dpleft": 36, 
	"dpright": 38, 
	"dpup": 37, 
	"leftshoulder": 32, 
	"leftstick": 47, 
	"lefttrigger": 34, 
	"rightshoulder": 33, 
	"rightstick": 46, 
	"righttrigger": 35, 
	"start": 28, 
	"x": 26, 
	"y": 27
}
var ps2_scheme: Dictionary = {
	"a": 24, 
	"b": 25, 
	"back": 30, 
	"dpdown": 39, 
	"dpleft": 36, 
	"dpright": 38, 
	"dpup": 37, 
	"leftshoulder": 32, 
	"leftstick": 47, 
	"lefttrigger": 34, 
	"rightshoulder": 33, 
	"rightstick": 46, 
	"righttrigger": 35, 
	"start": 31, 
	"x": 26, 
	"y": 27
}
var sw_scheme: Dictionary = {
	"a": 15, 
	"b": 14, 
	"back": 49, 
	"dpdown": 65, 
	"dpleft": 62, 
	"dpright": 64, 
	"dpup": 63, 
	"leftshoulder": 40, 
	"leftstick": 44, 
	"lefttrigger": 42, 
	"rightshoulder": 41, 
	"rightstick": 45, 
	"righttrigger": 43, 
	"start": 48, 
	"x": 17, 
	"y": 16
}
var generic_scheme: Dictionary = {
	"a": 52, 
	"b": 51, 
	"back": 30, 
	"dpdown": 39, 
	"dpleft": 36, 
	"dpright": 38, 
	"dpup": 37, 
	"leftshoulder": 32, 
	"leftstick": 47, 
	"lefttrigger": 34, 
	"rightshoulder": 33, 
	"rightstick": 46, 
	"righttrigger": 35, 
	"start": 31, 
	"x": 53, 
	"y": 50
}
var deck_scheme: Dictionary = {
	"a": 14, 
	"b": 15, 
	"back": 56, 
	"dpdown": 65, 
	"dpleft": 62, 
	"dpright": 64, 
	"dpup": 63, 
	"leftshoulder": 32, 
	"leftstick": 47, 
	"lefttrigger": 34, 
	"rightshoulder": 33, 
	"rightstick": 46, 
	"righttrigger": 35, 
	"start": 57, 
	"x": 16, 
	"y": 17
}



var _file_path: String = "user://settings.json"


var _opened: bool = false

var _err: int

func _notification(what: int) -> void :
	if what == NOTIFICATION_EXIT_TREE:
		CnfJson.queue_free()


func _enter_tree() -> void :
	
	if open_file() == OK:
		_opened = true
		
		check_file()
	
	
	var dir_locale: String = "res://localization/"
	for f in FuncsFiles.get_files(dir_locale):
		if f.get_extension() == "translation":
			TranslationServer.add_translation(
				ResourceLoader.load(dir_locale + f)
			)


func _input(event: InputEvent) -> void :
	if (
		event.is_action("fullscr_toggle") and event.is_pressed()
		and Features.has("pc") == true
	):
		var visual_mode: String = get_value("video", "visual_mode", "fullscreen")
		if visual_mode == "windowed":
			set_value("video", "visual_mode", "fullscreen")
		elif visual_mode in ["borderless", "fullscreen"]:
			set_value("video", "visual_mode", "windowed")

func open_file(config_file: String = _file_path) -> int:
	
	_err = CnfJson.load_file(config_file)
	
	if _err == ERR_FILE_NOT_FOUND:
		print_debug("config.gd: ERR_FILE_NOT_FOUND creating new configfile")
		
		_err = CnfJson.make_file_if_not_exists(config_file)
	
	if _err == OK:
		_file_path = config_file
	return _err


func check_file() -> int:
	
	

	
	_check_setting("video", "visual_mode", "fullscreen")
	
	_check_setting("video", "fps", 60)
	
	
	
	
	
	
	
	_check_setting("video", "window_resolution", 1)
	
	
	
	if Features.has("pc") == true:
		_check_setting("video", "filter", "none")
	else:
		_check_setting("video", "filter", "none")

	
	
	if Features.has("web") or Features.has("mobile"):
		
		
		_check_setting("video", "vfx_level", 1)
	else:
		_check_setting("video", "vfx_level", 2)
	
	
	
	

	
	
	
	
	
	
	
	
	var langlocale = TranslationServer.get_locale()
	
	if not CnfJson.has_section_key("other", "lang"):
		
		if (
			langlocale == "es"
			or langlocale.begins_with("es_")
			or langlocale.begins_with("es-")
		):
			langlocale = "es"
		






		
		else:
			langlocale = "en"
	_check_setting("gameplay", "lang", langlocale)
	
	
	
	_check_setting("gameplay", "icons_buttons", "keyboard")
	
	_check_setting("gameplay", "camera_shake", true)
	_check_setting("gameplay", "show_minimap", true)
	_check_setting("gameplay", "minimap_opacity", 0.7)
	_check_setting("gameplay", "player_afterimage", true)
	_check_setting("gameplay", "quickmenu_details", false)
	_check_setting("gameplay", "show_death_counter", false)
	
	_check_setting("difficulty", "unbreakable_will", false)
	_check_setting("difficulty", "dynamic_knockback", true)
	_check_setting("difficulty", "desperation_attack", true)
	
	
	_check_setting("misc", "preload_room", false)
	
	
	_check_setting("audio", "sfx", 0.9)
	_check_setting("audio", "bgm", 0.9)
	_check_setting("audio", "voice", 0.9)
	
	
	
	for action in InputMap.get_actions():
		for ev in InputMap.get_action_list(action):
			if ev is InputEventKey:
				
				_check_setting("keyboard", action, ev.get_scancode_with_modifiers())
			elif ev is InputEventMouseButton:
				
				_check_setting("keyboard", action, int(ev.button_index * - 1))
	
	
	
	
	_check_setting("controller", "dpup", "b" + str(JOY_DPAD_UP))
	_check_setting("controller", "dpdown", "b" + str(JOY_DPAD_DOWN))
	_check_setting("controller", "dpleft", "b" + str(JOY_DPAD_LEFT))
	_check_setting("controller", "dpright", "b" + str(JOY_DPAD_RIGHT))
	_check_setting("controller", "y", "b" + str(JOY_XBOX_Y))
	_check_setting("controller", "a", "b" + str(JOY_XBOX_A))
	_check_setting("controller", "b", "b" + str(JOY_XBOX_B))
	_check_setting("controller", "x", "b" + str(JOY_XBOX_X))
	_check_setting("controller", "back", "b" + str(JOY_SELECT))
	_check_setting("controller", "start", "b" + str(JOY_START))
	_check_setting("controller", "leftshoulder", "b" + str(JOY_L))
	_check_setting("controller", "rightshoulder", "b" + str(JOY_R))
	_check_setting("controller", "lefttrigger", "a" + str(JOY_ANALOG_L2))
	_check_setting("controller", "righttrigger", "a" + str(JOY_ANALOG_R2))
	_check_setting("controller", "leftstick", "b" + str(JOY_BUTTON_8))
	_check_setting("controller", "rightstick", "b" + str(JOY_BUTTON_9))
	
	_check_setting("controller", "lefty", "a" + str(JOY_AXIS_1))
	_check_setting("controller", "leftx", "a" + str(JOY_AXIS_0))
	
	_check_setting("controller", "righty", "a" + str(JOY_AXIS_3))
	_check_setting("controller", "rightx", "a" + str(JOY_AXIS_2))

	
	_check_setting("controller", "mapping_string", "")
	_check_setting("gamepad", "vibration", true)
	_check_setting("gamepad", "joystick_enabled", true)
	
	
	var selected_scheme: Dictionary = xb2_scheme
	
	
	if Features.has("switch"):
		selected_scheme = sw_scheme
	elif Features.has("ps"):
		selected_scheme = ps5_scheme
	elif Steam.is_init():
		if Steam.utils.is_running_on_steam_deck():
			selected_scheme = deck_scheme
	
	for sq_key in selected_scheme.keys():
		_check_setting("controller_helper", sq_key, selected_scheme[sq_key])
	
	
	
	if Features.has("switch"):
		_check_setting("gamepad", "ui_accept", "b")
		_check_setting("gamepad", "ui_cancel", "a")
	else:
		_check_setting("gamepad", "ui_accept", "a")
		_check_setting("gamepad", "ui_cancel", "b")
	
	_check_setting("gamepad", "ui_select", "back")
	_check_setting("gamepad", "ui_focus_next", "rightshoulder")
	_check_setting("gamepad", "ui_focus_prev", "leftshoulder")
	_check_setting("gamepad", "ui_left", "dpleft")
	_check_setting("gamepad", "ui_right", "dpright")
	_check_setting("gamepad", "ui_up", "dpup")
	_check_setting("gamepad", "ui_down", "dpdown")
	_check_setting("gamepad", "ui_start", "start")
	_check_setting("gamepad", "jump", "a")
	_check_setting("gamepad", "backdash", "leftshoulder")
	_check_setting("gamepad", "attack", "x")
	_check_setting("gamepad", "circuit", "rightshoulder")
	_check_setting("gamepad", "quickmenu", "b")
	
	

	
	_check_setting("touch_screen_btn", "opacity", 0.6)
	
	_check_setting("touch_screen_btn", "size", 1.3)
	
	for vp in default_virtualpad_positions:
		_check_setting(
			"touch_screen_btn", vp, 
			default_virtualpad_positions[vp]
		)
	
	
	if not CnfJson.has_section_key("touch_screen_btn", "visible"):
		if Features.has("mobile"):
			CnfJson.set_value("touch_screen_btn", "visible", true)
		else:
			CnfJson.set_value("touch_screen_btn", "visible", false)
	
	
	
	if not CnfJson.has_section_key("touch_screen_btn", "always_visible"):
		CnfJson.set_value(
			"touch_screen_btn", "always_visible", 
			false
		)
	
	
	if not CnfJson.has_section_key("touch_screen_btn", "joystick"):
		CnfJson.set_value("touch_screen_btn", "joystick", true)

	
	
	
	
	
	
	_err = CnfJson.save_file(_file_path)
	
	
	if _err != OK:
		print_debug("config.gd: error saving configfile: %d" % [_err])
	
	return _err


func get_value(section: String, key: String, default_value):
	
	
	return CnfJson.get_value(section, key, default_value)


func set_value(section: String, key: String, value) -> void :
	
	
	if value is String:
		if value.is_valid_integer():
			value = int(value)
		elif value.is_valid_float():
			value = float(value)
	
	
	if section == "audio" and key in ["sfx", "bgm", "voice"]:
		value = value / 100

	CnfJson.set_value(section, key, value)
	
	_err = CnfJson.save_file(_file_path)
	
	if _err != OK:
		print_debug("config.gd: error saving configfile: %d" % [_err])
	
	else:
		
		_apply_setting(section, key, value)
		
		emit_signal("value_changed", section, key, value)

func get_section_keys(section: String) -> PoolStringArray:
	var keys: PoolStringArray
	keys = CnfJson.get_section_keys(section)
	return keys



func _check_setting(section: String, key: String, value) -> void :
	if not CnfJson.has_section_key(section, key):
		CnfJson.set_value(section, key, value)
	_apply_setting(section, key, CnfJson.get_value(section, key, value))


func _apply_setting(section: String, key: String, value) -> void :

	var new_event
	
	match section:
		
		"video":
			match key:
				"visual_mode":
					if value == "windowed":
						OS.set_window_fullscreen(false)
						OS.set_borderless_window(false)
					elif value == "borderless":
						OS.set_window_fullscreen(false)
						
						OS.set_borderless_window(true)
					elif value == "fullscreen":
						OS.set_window_fullscreen(true)
						OS.set_borderless_window(false)
				"fps":
					Engine.set_target_fps(value)
				"vfx_level":
					vfx_level = value
				"window_resolution":
					var base_res: = Vector2(341, 192)
					match value:
						- 1:
							
							OS.set_window_size(OS.get_screen_size())
						0:
							OS.set_window_size(base_res * 4)
						1:
							OS.set_window_size(base_res * 3)
						2:
							OS.set_window_size(base_res * 2)
						3:
							OS.set_window_size(base_res)
						
					
					var win_size = OS.get_window_size()
					var screen_size = OS.get_screen_size()
					var center = Vector2(
						screen_size.x / 2 - win_size.x / 2, 
						screen_size.y / 2 - win_size.y / 2
					)
					OS.set_window_position(center)
		
		
		"audio":
			match key:
				"sfx":
					AudioServer.set_bus_volume_db(
						AudioServer.get_bus_index("Effects"), linear2db(value)
					)
				"bgm":
					AudioServer.set_bus_volume_db(
						AudioServer.get_bus_index("Music"), linear2db(value)
					)
				"voice":
					AudioServer.set_bus_volume_db(
						AudioServer.get_bus_index("Voice"), linear2db(value)
					)
		
		"keyboard":
			for ev in InputMap.get_action_list(key):
				
				if key == "fullscr_toggle":
					break
				if (
					ev is InputEventKey
					or ev is InputEventMouseButton
				):
					
					InputMap.action_erase_event(key, ev)
					
					
					
					if value >= 0:
						new_event = InputEventKey.new()
						
						new_event.scancode = value
					
					else:
						new_event = InputEventMouseButton.new()
						
						
						new_event.button_index = abs(value)
					
					InputMap.action_add_event(key, new_event)
					break
		
		"gamepad":
			if key == "joystick_enabled":
				joystick_enabled = value
			elif key == "vibration":
				gamepad_vibration = value
		
		"gameplay":
			match key:
				"lang":
					TranslationServer.set_locale(value)
				"icons_buttons":
					icons_buttons = value
				"camera_shake":
					camera_shake = value
