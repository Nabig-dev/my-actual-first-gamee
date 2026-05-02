extends Area2D

signal interact_requested

export var down_action: bool

onready var Helper = $HelperIconBtn
onready var TimerAppear = $TimerAppearHelper

var _player_entered: bool

var _disabled: bool

func _ready() -> void :
	
	if down_action == true:
		$HelperIconBtn.action = "ui_down"
		$HelperIconBtn.update_icon()
	
	Helper.visible = false

func _process(_delta: float) -> void :
	if (
		_player_entered == true
		and Helper.visible == true
		and (
			down_action == true and Input.is_action_just_pressed("ui_down")
			or Input.is_action_just_pressed("ui_up")
		)
		and VarsGlobal.Player.enabled_input == true
	):
		TimerAppear.start()
		Helper.visible = false
		emit_signal("interact_requested")

func set_disabled() -> void :
	if _disabled == false:
		visible = false
		_player_entered = false
		_disabled = true
		disconnect(
			"area_entered", self, 
			"_on_IteractableArea2DIndicator_area_entered"
		)
		disconnect(
			"area_exited", self, 
			"_on_IteractableArea2DIndicator_area_exited"
		)

func _on_IteractableArea2DIndicator_area_entered(_area: Area2D) -> void :
	if VarsGlobal.Player.enabled_input == true:
		Helper.visible = true
		_player_entered = true

func _on_IteractableArea2DIndicator_area_exited(_area: Area2D) -> void :
	Helper.visible = false
	_player_entered = false

func _on_TimerAppearHelper_timeout() -> void :
	if _player_entered == true:
		Helper.visible = true
