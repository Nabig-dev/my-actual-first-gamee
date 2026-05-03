extends Node

var _gamepad_dir_pressed: String

onready var TimerCoolDown = $TimerCoolDown
onready var TimerCoolDownAction = $TimerCoolDownAction

func _process(_delta: float) -> void :
	if (
		_gamepad_dir_pressed.empty() == false
		and TimerCoolDownAction.is_stopped() == true
	):
		TimerCoolDownAction.start(0.05)
		_parse_event(_gamepad_dir_pressed)

func _input(event: InputEvent) -> void :

	if event is InputEventJoypadButton:
		
		if event.is_pressed() == true:
			
			TimerCoolDown.start(0.3)
			yield(TimerCoolDown, "timeout")
			
			if event.is_action("ui_left"):
				_gamepad_dir_pressed = "ui_left"
			elif event.is_action("ui_right"):
				_gamepad_dir_pressed = "ui_right"
		
		else:
			TimerCoolDown.stop()
			_parse_event(_gamepad_dir_pressed, false)
			_gamepad_dir_pressed = ""

func _parse_event(act: String, pressed: bool = true) -> void :
	var a: = InputEventAction.new()
	a.action = act
	a.pressed = pressed
	Input.parse_input_event(a)
