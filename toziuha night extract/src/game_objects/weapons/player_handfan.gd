extends Node2D

var dir: int = 1

var _first_move_done: bool = false

var _max_speed: float = 250.0
var _speed: float = 125.0

onready var Tw = $Tween
onready var NodeSprite = $XandriaSubweapons

func _ready() -> void :
	
	ElementalCircuits.apply_mana_cost(
		GVar.EC_MODE.SUBWEAPON, 
		GVar.EC_SUBWEAPON.HANDFAN
	)

	$GhostTrail.start_trail(10, 0.05)
	
	NodeSprite.scale.x = dir
	
	Tw.interpolate_property(
		NodeSprite, "rotation_degrees", 0, 360 * dir, 0.3
	)
	Tw.start()

func _physics_process(delta: float) -> void :
	
	if _speed >= _max_speed and _first_move_done == false:
		dir = dir * - 1
		_speed = - 125.0
		_first_move_done = true
	
	if _speed > 0:
		global_position.x += (_speed * dir) * delta
	
	_speed += 2.5

func _on_VisibilityEnabler2D_screen_exited() -> void :
	if _first_move_done:
		queue_free()


func _on_TimerWoosh_timeout() -> void :
	Audio.play_sfx("woosh_whip_m")
