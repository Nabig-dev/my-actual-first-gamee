extends KinematicBody2D

var gravity: float = 1000
var velocity: Vector2

var _enabled_gravity: bool = false

func _ready() -> void :
	$AnimationPlayer.play("show")

func _physics_process(delta: float) -> void :
	
	if _enabled_gravity == false:
		velocity.y = 0
		return
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity)

func enable_gravity() -> void :
	_enabled_gravity = true
	$GhostTrail.start_trail(0, 0.1)
	
func sfx_start() -> void :
	Audio.play_sfx("ec_ice_start")
func sfx_end() -> void :
	Audio.play_sfx("impact_mineral")
	Audio.play_sfx("ec_ice_end")

func _on_AreaDetectFloor_body_entered(_body: Node) -> void :
	$GhostTrail.stop_trail()
	$AnimationPlayer.play("destroyed")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
	Gamepad.start_vibration(0, 0.4, 0.4, 0.5)
