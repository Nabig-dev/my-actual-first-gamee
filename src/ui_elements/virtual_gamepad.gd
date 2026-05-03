extends Control



export var edit_mode: bool = true
export var scene_path_on_close: String

var _moving_item: bool
var _item_to_move: String

var _quickmenu_btn_pressed: bool

var _set_selected_to_change: int = - 1

var _touch_index: int = - 1

onready var _opacity: float = Config.get_value("touch_screen_btn", "opacity", 0.5)
onready var _size: float = Config.get_value("touch_screen_btn", "size", 1.5)

onready var Area2DQuickMenuTouch = $Area2DQuickMenuTouch

func _ready() -> void :
	
	$BtnClose.visible = false
	$VBxOptions.visible = false
	$BG.visible = false
	
	get_node("%SetMenu").visible = false
	get_node("%Commands").visible = false
	
	hide_on_touch()
	
	
	
	Gamepad.connect(
		"gamepad_connection_changed", self, 
		"_on_GamepadConnection"
	)
	
	
	_on_BtnOpacity_pressed("+")
	
	
	_on_BtnSize_pressed("-")
	
	
	for vp in get_tree().get_nodes_in_group("vpad_object"):
		get_node("%" + vp.name).position = Config.get_value(
			"touch_screen_btn", vp.name, 
			Config.default_virtualpad_positions[vp.name]
		)
	
	
	
	if (
		Config.get_value("touch_screen_btn", "joystick", false) == true
		and edit_mode == false
	):
		$ControlL / Dpad / VirtualJoystick.visible = true
		$ControlL / Dpad / Left.visible = false
		$ControlL / Dpad / Right.visible = false
		$ControlL / Dpad / Up.visible = false
		$ControlL / Dpad / Down.visible = false
	else:
		$ControlL / Dpad / VirtualJoystick.queue_free()

	if edit_mode == false:
		return
	
	
	
	$VBxOptions.visible = true
	$BtnClose.visible = true
	$BG.visible = true
	
	for vp in get_tree().get_nodes_in_group("vpad_button"):
		vp.passby_press = false
		vp.action = ""
		vp.connect("pressed", self, "_VPButton_pressed", [vp.name])
		vp.connect("released", self, "_VPButton_released")

func _process(_delta: float) -> void :
	
	if _moving_item == true and _item_to_move.empty() == false:
		
		if _item_to_move == "Dpad":
			get_node("%" + _item_to_move).global_position = get_global_mouse_position()
		else:
			
			get_node("%" + _item_to_move).global_position = (
				get_global_mouse_position()
				- Vector2(15 * _size, 15 * _size)
			)

func _input(event: InputEvent) -> void :
	
	if edit_mode == true:
		return
	
	
	
	
	
	if event is InputEventScreenTouch:
		if (
			event.pressed == true and _touch_index == - 1
			and _quickmenu_btn_pressed == true
		):
			_touch_index = event.index
	if (
		event is InputEventScreenDrag
		and _touch_index == event.index
	):
		Area2DQuickMenuTouch.global_position = event.position

func stop_joystick() -> void :
	if Config.get_value("touch_screen_btn", "joystick", false) == true:
		$ControlL / Dpad / VirtualJoystick.stop_update_pos()

func hide_on_touch() -> void :

	
	if edit_mode == true:
		return
	
	var gamepad_connected: bool = Gamepad.is_controller_connected()
	var vpad_visible: bool = Config.get_value(
		"touch_screen_btn", "visible", false
	)
	var vpad_always_visible: bool = Config.get_value(
		"touch_screen_btn", "always_visible", false
	)
	
	if vpad_visible == false:
		visible = false
		return
	
	if gamepad_connected == true and vpad_always_visible == false:
		visible = false
	else:
		visible = true

func _set_visible_commands() -> void :
	get_node("%BtnWhipSpin").visible = ElementalCircuits.was_obtained(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.WHIP_SPIN
	)
	get_node("%BtnWhipCrush").visible = ElementalCircuits.was_obtained(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.WHIP_CRUSH
	)

func _on_hud_updated() -> void :
	
	if get_node("%BtnWhipSpin").visible == true:
		if VarsGlobal.game_data["player_bl_now"] >= 20:
			get_node("%BtnWhipSpin").modulate.a = 1.0
		else:
			get_node("%BtnWhipSpin").modulate.a = 0.4

	if get_node("%BtnWhipCrush").visible == true:
		if VarsGlobal.game_data["player_bl_now"] >= VarsGlobal.game_data["player_bl_max"]:
			get_node("%BtnWhipCrush").modulate.a = 1.0
		else:
			get_node("%BtnWhipCrush").modulate.a = 0.4

func _on_circuit_obtained() -> void :
	_set_visible_commands()

func _VPButton_pressed(node_name: String) -> void :
	_moving_item = true
	
	if node_name in [
		"Left", 
		"Right", 
		"Up", 
		"Down", 
	]:
		_item_to_move = "Dpad"
	else:
		_item_to_move = node_name
	
func _VPButton_released() -> void :
	_moving_item = false
	_item_to_move = ""

func _on_BtnOpacity_pressed(opt: String) -> void :
	if opt == "+":
		_opacity = FuncsNumbers.add_value(
			0.1, _opacity, 1.0
		)
	else:
		_opacity = FuncsNumbers.decrease_value(
			0.1, _opacity, 0.1
		)
		
	for n in get_tree().get_nodes_in_group("vpad_object"):
		if n.name == "Dpad":
			n.modulate.a = _opacity
		else:
			n.self_modulate.a = _opacity

func _on_BtnSize_pressed(opt: String) -> void :
	if opt == "+":
		_size = FuncsNumbers.add_value(
			0.1, _size, 2.0
		)
	else:
		_size = FuncsNumbers.decrease_value(
			0.1, _size, 1.0
		)
	get_tree().call_group(
		"vpad_object", "set_scale", Vector2(
			_size, _size
		)
	)

func _on_BtnClose_pressed() -> void :
	if scene_path_on_close.empty() == false:
		Audio.play_sfx("ui_cancel")
		SceneChanger.change_scene(scene_path_on_close)

func _on_BtnSave_pressed() -> void :
	Audio.play_sfx("ui_success")
	Config.set_value("touch_screen_btn", "opacity", _opacity)
	Config.set_value("touch_screen_btn", "size", _size)
	for vp in get_tree().get_nodes_in_group("vpad_object"):
		Config.set_value(
			"touch_screen_btn", vp.name, 
			get_node("%" + vp.name).position
		)

func _on_BtnReset_pressed() -> void :
	Audio.play_sfx("ui_accept")
	
	for vp_p in Config.default_virtualpad_positions:
		get_node("%" + vp_p).position = Config.default_virtualpad_positions[vp_p]
	
	_opacity = 0.6
	$ControlL.modulate.a = _opacity
	$ControlR.modulate.a = _opacity
	
	_size = 1.3
	get_tree().call_group(
		"vpad_object", "set_scale", Vector2(
			_size, _size
		)
	)




func _on_X2_pressed() -> void :
	if edit_mode == false:
		VarsGlobal.Player.whip_attack("atk-m")


func _on_VirtualGamepad_visibility_changed() -> void :
	if visible == false:
		return
	hide_on_touch()


func _on_GamepadConnection(_connected: bool) -> void :
	hide_on_touch()


func _on_B_pressed() -> void :
	if edit_mode == false and ElementalCircuits.was_obtained(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.MULTIPLE_EQUIPMENT
	) == true:
		get_node("%SetMenu").visible = true
		_quickmenu_btn_pressed = true

func _on_B_released() -> void :
	if edit_mode == false:
		get_node("%SetMenu").visible = false
		
		_quickmenu_btn_pressed = false
		_touch_index = - 1
		
		
		Area2DQuickMenuTouch.global_position = Vector2.ZERO
		
		if _set_selected_to_change >= 0:
			Audio.play_sfx("ui_subweapon_switch")
			VarsGlobal.game_data["player_current_set"] = _set_selected_to_change
			VarsGlobal.GameInterface.update_set_info_quick()
			VarsGlobal.GameInterface.update_sets_labels()
			VarsGlobal.GameInterface.emit_signal("set_changed")

func _on_SetArea_mouse_entered(set: String) -> void :
	if edit_mode == true:
		return
	get_node("%Set" + set + "/LightSet").visible = true
	match set:
		"A":
			_set_selected_to_change = 0
		"B":
			_set_selected_to_change = 1
		"C":
			_set_selected_to_change = 2
		
func _on_SetArea_mouse_exited(set: String) -> void :
	get_node("%Set" + set + "/LightSet").visible = false
	_set_selected_to_change = - 1


func _on_C_pressed() -> void :
	get_node("%Commands").visible = not get_node("%Commands").visible

func _on_TimerConnect_timeout() -> void :
	if edit_mode == false:
		VarsGlobal.GameInterface.connect(
			"hud_updated", self, "_on_hud_updated"
		)
		VarsGlobal.GameScenario.connect(
			"circuit_obtained", self, "_on_circuit_obtained"
		)
		_set_visible_commands()

func _on_command_btn_pressed(nodename: String) -> void :
	
	if (
		get_node("%" + nodename).modulate.a != 1.0
		or edit_mode == true
	):
		return
	
	match nodename:
		"BtnWhipCrush":
			VarsGlobal.Player.execute_command("whip_h")
		
		"BtnWhipSpin":
			VarsGlobal.Player.execute_command("whip_spin")


func _on_Area2DQuickMenuTouch_area_entered(area: Area2D) -> void :
	if area.name in ["SetA", "SetB", "SetC"]:
		_on_SetArea_mouse_entered(
			area.name.replace("Set", "")
		)

func _on_Area2DQuickMenuTouch_area_exited(area: Area2D) -> void :
	if area.name in ["SetA", "SetB", "SetC"]:
		_on_SetArea_mouse_exited(
			area.name.replace("Set", "")
		)

func _on_VirtualJoystick_update_pos(pos: Vector2) -> void :
	
	var dirs: Array = $ControlL / Dpad / VirtualJoystick.get_dirs(pos)
	for dir in ["left", "right", "up", "down"]:
		if dir in dirs:
			Input.action_press("ui_" + dir)
		else:
			Input.action_release("ui_" + dir)

func _on_VirtualJoystick_stop_update_pos(_pos: Vector2) -> void :
	for dir in ["left", "right", "up", "down"]:
		Input.action_release("ui_" + dir)
