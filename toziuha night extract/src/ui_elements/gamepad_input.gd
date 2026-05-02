extends Control



export var active: bool = true

var GamepadBtnIndicators: Array

var controller_names: Array
var controller_codes: Array

func _ready() -> void :
	
	controller_names = Config.get_section_keys("controller")
	
	for n in controller_names:
		controller_codes.append(Config.get_value("controller", n, "b0"))
	
	GamepadBtnIndicators = $GamepadTester.get_children()
	
	for nodebtn in GamepadBtnIndicators:
		nodebtn.visible = false

func _process(_delta: float) -> void :
	
	$GamepadTester / l_joy_left.visible = Input.is_action_pressed("ui_joy_left")
	$GamepadTester / l_joy_right.visible = Input.is_action_pressed("ui_joy_right")
	$GamepadTester / l_joy_up.visible = Input.is_action_pressed("ui_joy_up")
	$GamepadTester / l_joy_down.visible = Input.is_action_pressed("ui_joy_down")
	
	$GamepadTester / r_joy_left.visible = Input.is_action_pressed("r_joy_left")
	$GamepadTester / r_joy_right.visible = Input.is_action_pressed("r_joy_right")
	$GamepadTester / r_joy_up.visible = Input.is_action_pressed("r_joy_up")
	$GamepadTester / r_joy_down.visible = Input.is_action_pressed("r_joy_down")

func _input(event: InputEvent) -> void :

	if event is InputEventJoypadButton or event is InputEventJoypadMotion:

		var code: String

		if event is InputEventJoypadButton:
			code = "b%d" % [event.button_index]
		elif event is InputEventJoypadMotion:
			code = "a%d" % [event.axis]

		if code.empty() == true:
			return
		
		if code in controller_codes:
			var idx: int = controller_codes.find(code)
			var name_btn: String = controller_names[idx]
			var node_show: Sprite = get_node_or_null("GamepadTester/%s" % [name_btn])
			
			if (
				code.begins_with("b")
				or (
					code.begins_with("a")
					and name_btn.ends_with("x") == false
					and name_btn.ends_with("y") == false
				)
			):
				if node_show == null:
					return
				
				if event.is_pressed():
					node_show.visible = true
				else:
					node_show.visible = false
			


































