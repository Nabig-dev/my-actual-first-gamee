extends HBoxContainer

signal value_changed(value_now)

export var text: String = "SLOT"
export var min_value: int = 0
export var max_value: int = 10
export var current_value: int = min_value

var _is_focused: bool

func _ready() -> void :
	_update_label()

func _process(_delta: float) -> void :
	if _is_focused == false:
		return
	if Input.is_action_just_pressed("ui_left"):
		_on_BtnDown_pressed()
	elif Input.is_action_just_pressed("ui_right"):
		_on_BtnUp_pressed()

func set_disabled(disable: bool) -> void :
	$BtnUp.disabled = disable
	$BtnDown.disabled = disable

func _update_label() -> void :
	$Label.text = tr(text) + ": "
	$Label2.text = str(current_value)

func _on_BtnDown_pressed() -> void :
	Audio.play_sfx("ui_changed_value")
	current_value -= 1
	if current_value < min_value:
		current_value = max_value
	emit_signal("value_changed", current_value)
	_update_label()

func _on_BtnUp_pressed() -> void :
	Audio.play_sfx("ui_changed_value")
	current_value += 1
	if current_value > max_value:
		current_value = min_value
	emit_signal("value_changed", current_value)
	_update_label()


func _on_CustomSpinBox_focus_entered() -> void :
	_is_focused = true
	get_node("%LblFocusInd").visible = true
func _on_CustomSpinBox_focus_exited() -> void :
	_is_focused = false
	get_node("%LblFocusInd").visible = false
