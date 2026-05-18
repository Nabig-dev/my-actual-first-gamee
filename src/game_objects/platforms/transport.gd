extends Node2D

export var chain_node: NodePath

export (float, 0.04, 1.0) var speed = 0.08

var ChainNode: Line2D

var active: bool

var dir: int = 1

var max_speed: float = 1

var _player_entered: bool

var _usable: bool

var _can_interact: bool = true

var _switch_used: bool

onready var Tw: = $TransportPlatform / Tween

onready var HelperIconBtn = $Platform / HelperIconBtn

onready var PathNode = $TransportPlatform
onready var PathFollowNode = $TransportPlatform / PathFollow2D
onready var AnimPlay = $TransportPlatform / AnimationPlayer
onready var SwitchSprite = $Platform / Switch
onready var GearLight = $Platform / Gear1Light
onready var VisibilityNotify = $Platform / VisibilityNotifier2D

onready var TimerReachedLimit = $TimerReachedLimit

func _ready() -> void :
	GearLight.visible = false
	HelperIconBtn.visible = false
	
	
	PathFollowNode.h_offset = position.x * - 1
	PathFollowNode.v_offset = position.y * - 1
	
	max_speed = 0
	
	if chain_node.is_empty() == false:
		ChainNode = get_node(chain_node)
	else:
		return
	
	var chain_points: Array = ChainNode.points
	
	
	if chain_points.size() >= 2:
		PathNode.curve = Curve2D.new()
		for p_idx in ChainNode.get_point_count():
			PathNode.curve.add_point(
				ChainNode.get_point_position(p_idx)
			)
		_usable = true

func _physics_process(delta: float) -> void :

	if (
		_player_entered == true
		and _can_interact == true
		and Input.is_action_just_pressed("ui_down")
	):
		
		_switch_used = true
		
		
		if PathFollowNode.unit_offset == 1.0 and active == false:
			dir = - 1
			AnimPlay.play_backwards("spin")
			start_speed()
		
		
		elif PathFollowNode.unit_offset == 0.0 and active == false:
			dir = 1
			AnimPlay.play("spin")
			start_speed()
		
		
		else:
			
			if max_speed > 0.0:
				stop_speed()
			else:
				start_speed()
	
	AnimPlay.playback_speed = max_speed
	PathFollowNode.unit_offset += ((speed * delta) * max_speed) * dir

	if (
		max_speed > 0.0
		and (PathFollowNode.unit_offset == 1.0 or 
		PathFollowNode.unit_offset == 0.0)
		and TimerReachedLimit.is_stopped() == true
	):
		TimerReachedLimit.start(1)
		GearLight.visible = false
		if VisibilityNotify.is_on_screen() == true:
			Audio.play_sfx("motor_stop")
			Audio.play_sfx("motor_stop_b")
		
		VarsGlobal.GameScenario.CameraNode.start_shake(
			0.5, false, true
		)
		max_speed = 0
		if active == true:
			active = false

func start_speed() -> void :
	
	
	if (
		VarsGlobal.Player != null
		and PathFollowNode.unit_offset != 1.0
		and PathFollowNode.unit_offset != 0.0
	):
		dir = VarsGlobal.Player.facing
	
	GearLight.visible = true
	_can_interact_updated(false)
	if VisibilityNotify.is_on_screen() == true:
		Audio.play_sfx("ui_changed_value2")
		Audio.play_sfx("motor_start")
	SwitchSprite.flip_h = not SwitchSprite.flip_h
	HelperIconBtn.visible = false
	active = true
	Tw.remove_all()
	Tw.interpolate_property(
		self, "max_speed", 0, 1.0, 2
	)
	Tw.start()
	yield(Tw, "tween_completed")
	_can_interact_updated(true)
	
	

func stop_speed() -> void :
	GearLight.visible = false
	_can_interact_updated(false)
	if VisibilityNotify.is_on_screen() == true:
		Audio.play_sfx("ui_changed_value2")
		Audio.play_sfx("motor_stop")
	SwitchSprite.flip_h = not SwitchSprite.flip_h
	active = false
	Tw.remove_all()
	Tw.interpolate_property(
		self, "max_speed", max_speed, 0.0, 1
	)
	Tw.start()
	yield(Tw, "tween_completed")
	_can_interact_updated(true)

func _can_interact_updated(can_intc: bool) -> void :
	_can_interact = can_intc
	if _can_interact == true:
		SwitchSprite.material.set_shader_param("line_color", Color("a8ffffff"))
	else:
		SwitchSprite.material.set_shader_param("line_color", Color("00ffffff"))
	if _player_entered == true:
		HelperIconBtn.visible = _can_interact

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	if _usable == true:
		_player_entered = true
		if _can_interact == true:
			HelperIconBtn.visible = true

func _on_AreaDetectPlayer_area_exited(_area: Area2D) -> void :
	_player_entered = false
	HelperIconBtn.visible = false

func _on_VisibilityNotifier2D_screen_exited() -> void :
	if _usable == true and active == true:
		dir = dir * - 1

func _on_VisibilityNotifier2D_screen_entered() -> void :
	if _usable == true and active == true:
		stop_speed()

func _on_TimerCheckPlayerPosition_timeout() -> void :
	if _usable == true:
		
		if (
			global_position.x > VarsGlobal.Player.global_position.x
			or global_position.y > VarsGlobal.Player.global_position.y
		):
			PathFollowNode.unit_offset = 0
			dir = 1
		else:
			PathFollowNode.unit_offset = 1
			dir = - 1
