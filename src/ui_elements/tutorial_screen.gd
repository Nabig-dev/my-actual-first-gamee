extends Control

var ElementalCircuitNode = preload("res://src/game_objects/elemental_circuit.tscn")

signal started
signal ended

var selected_content: int = 0

var current_page: int = 0
var max_page: int = 1

var ContentNodes: Array

onready var Tw = $Tween

func _ready() -> void :
	modulate.a = 0
	
	var gamepad_connected: bool = Gamepad.is_controller_connected()
	var vpad_visible: bool = Config.get_value(
		"touch_screen_btn", "visible", false
	)
	var vpad_always_visible: bool = Config.get_value(
		"touch_screen_btn", "always_visible", false
	)

	
	
	if (
		vpad_visible == true
		and (gamepad_connected == false or vpad_always_visible == true)
	):
		$Content / WhipM / Control / HBoxContainer.visible = false
		$Content / WhipM / Control / HBoxContainer2.visible = true
		
		$Content / QuickMenuAndInventory / Control / NoTouch.visible = false
		$Content / QuickMenuAndInventory / Control / Touch.visible = true
	else:
		$Content / WhipM / Control / HBoxContainer.visible = true
		$Content / WhipM / Control / HBoxContainer2.visible = false
		
		$Content / QuickMenuAndInventory / Control / NoTouch.visible = true
		$Content / QuickMenuAndInventory / Control / Touch.visible = false

func start_circuit_message(circuit: int, type: int) -> void :
	
	if type == GVar.EC_MODE.ABILITY and circuit == GVar.EC_ABILITY.MULTIPLE_EQUIPMENT:
		start(2)
		return
	
	$Content / HowToCircuit / Control / Control.add_child(
		ElementalCircuitNode.instance()
	)
	
	$Content / HowToCircuit / Control / Control / ElementalCircuit.position = $Content / HowToCircuit / Control / Control / PositionCircuit.position
	
	var CircuitNode: Node2D = $Content / HowToCircuit / Control / Control / ElementalCircuit
	CircuitNode.circuit_mode = type
	if type == 0:
		CircuitNode.action = circuit
	elif type == 1:
		CircuitNode.ability = circuit
	$Content / HowToCircuit / Control / Label.text = ElementalCircuits.get_circuit_string(type, circuit, true)
	$Content / HowToCircuit / Control / Label2.text = tr(
		"%s_DESC" % [ElementalCircuits.get_circuit_string(type, circuit)]
	)
	start(12)

func start(content_idx: int = 0) -> void :
	
	selected_content = content_idx
	
	get_node("%ButtonNext").disabled = true
	
	Tw.interpolate_property(
		self, "modulate", 
		Color("00ffffff"), Color("ffffff"), 0.5
	)
	Tw.start()
	
	var i = 0
	for c in get_node("%Content").get_children():
		if i != selected_content:
			c.visible = false
		else:
			c.visible = true
			ContentNodes = c.get_children()
		i += 1
	
	
	max_page = ContentNodes.size() - 1

	_on_ButtonTuto_pressed("none")
	
	emit_signal("started")
	
	yield(get_tree().create_timer(1.5), "timeout")
	get_node("%ButtonNext").disabled = false

func _process(_delta: float) -> void :
	
	if modulate.a != 1:
		return
	
	if Input.is_action_just_pressed("ui_left") and get_node("%ButtonPrev").disabled == false:
			_on_ButtonTuto_pressed("prev")
	elif Input.is_action_just_pressed("ui_right") and get_node("%ButtonNext").disabled == false:
			_on_ButtonTuto_pressed("next")

func _on_ButtonTuto_pressed(opt: String) -> void :
	
	if opt != "none":
		current_page = FuncsArrays.get_new_position_on_array(
			ContentNodes, current_page, opt
		)
	
	if opt == "next" and get_node("%ButtonNext").text == tr("CLOSE"):

		Audio.play_sfx("ui_cancel")
		
		get_node("%ButtonPrev").disabled = true
		get_node("%ButtonNext").disabled = true
		
		Tw.interpolate_property(
			self, "modulate", 
			modulate, Color("00ffffff"), 0.5
		)
		Tw.start()

		return
	
	if opt != "none":
		Audio.play_sfx("ui_changed_value")
	
	
	for c in ContentNodes:
		c.visible = false
	ContentNodes[current_page].visible = true
	
	
	if current_page == 0:
		get_node("%ButtonPrev").disabled = true
	else:
		get_node("%ButtonPrev").disabled = false
	
	
	if current_page == max_page:
		get_node("%ButtonNext").text = tr("CLOSE")
	else:
		get_node("%ButtonNext").text = tr("NEXT")

func _on_Tween_tween_completed(_object: Object, key: NodePath) -> void :
	if key == ":modulate" and modulate.a == 0:
		emit_signal("ended")
		queue_free()
