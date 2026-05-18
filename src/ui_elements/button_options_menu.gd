extends Button

signal value_changed(btn_name, is_bool, value, section, key)
		
export var title_btn: = "Panel BTN"

export var section: String
export var key: String

export var bool_value = false

export var item_idx: int = 0

export (Array, String) var items_values
export (Array, String) var items_text

var _is_bool = false
var _is_focused = false

onready var LblValue = $HBoxContainer / LblVal
onready var ArrowL = $HBoxContainer / ArrowL
onready var ArrowR = $HBoxContainer / ArrowR
onready var TweenNode = $Tween
onready var ArrowLIcon = $HBoxContainer / ArrowL / IconMovible
onready var ArrowRIcon = $HBoxContainer / ArrowR / IconMovible

func _ready() -> void :
	
	Config.connect("value_changed", self, "_on_Config_updated")
	_on_Button_focus_exited()
	$HBoxContainer / Label.text = title_btn
	
	
	if items_values.size() < 1:
		_is_bool = true
	
	_show_actual_value()

func _process(_delta: float) -> void :
	
	
	if not _is_focused:
		return
		
	
	if Input.is_action_just_pressed("ui_left"):
		_activate_arrow_tween("left")
	if Input.is_action_just_pressed("ui_right"):
		_activate_arrow_tween("right")
	
	
	if _is_bool and (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")):
		bool_value = not bool_value
		_update_value()
		Audio.play_sfx("ui_changed_value")
	
	
	if not _is_bool and Input.is_action_just_pressed("ui_left"):
		item_idx = FuncsArrays.get_new_position_on_array(items_values, item_idx, "prev")
		_update_value()
		Audio.play_sfx("ui_changed_value")

	
	if not _is_bool and Input.is_action_just_pressed("ui_right"):
		item_idx = FuncsArrays.get_new_position_on_array(items_values, item_idx, "next")
		_update_value()
		Audio.play_sfx("ui_changed_value")
	

func _show_actual_value() -> void :
	
	if section == "" and key == "":
		return
	
	
	if _is_bool:
		bool_value = Config.get_value(section, key, bool_value)
	
	
	else:
		var actual_value = Config.get_value(section, key, items_values[item_idx])
		
		var i: int = 0
		for val in items_values:
			
			if String(val).is_valid_integer():
				val = int(val)
			if String(val).is_valid_float():
				val = float(val)
			
			if val == actual_value:
				item_idx = i
				break
			i += 1
	
	_update_value(false)

func _update_value(emitsignal: bool = true):
	if _is_bool == true:
		if bool_value == true:
			LblValue.text = tr("YES")
		else:
			LblValue.text = tr("NO")
		
		if emitsignal:
			emit_signal("value_changed", name, _is_bool, bool_value, section, key)
	
	else:
		LblValue.text = tr(items_text[item_idx])
		
		if emitsignal:
			emit_signal("value_changed", name, _is_bool, items_values[item_idx], section, key)

func _on_Button_focus_entered() -> void :
	ArrowL.modulate.a = 1
	ArrowR.modulate.a = 1
	_is_focused = true

func _on_Button_focus_exited() -> void :
	ArrowL.modulate.a = 0
	ArrowR.modulate.a = 0
	_is_focused = false

func _on_Config_updated(_section, _key, _value) -> void :
	
	_show_actual_value()
	_update_value(false)

func _on_Button_value_changed(_btn_name, is_bool, value, _section, _key) -> void :
	
	if $Timer.get_time_left() != 0:
		return
	
	
	if is_bool:
		value = bool(value)

	
	if section != "" and key != "":
		
		Config.set_value(_section, _key, value)

func _activate_arrow_tween(arrow = "left") -> void :
	
	var obj
	var end_scale
	
	if arrow == "left":
		obj = ArrowLIcon
		end_scale = Vector2(0.95, 1)
	else:
		obj = ArrowRIcon
		end_scale = Vector2(1.05, 1)
		
	TweenNode.interpolate_property(obj, "rect_scale", Vector2(1, 1), end_scale, 0.5)
	TweenNode.start()
	TweenNode.interpolate_property(obj, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5)
	TweenNode.start()
