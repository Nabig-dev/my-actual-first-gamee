extends KinematicBody2D

var angle_variation: float
var speed: float = 600
var velocity: Vector2
var moving: bool
var update_angle: bool

var time_to_start: float = 1

func _ready() -> void :
	sfx_start()
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")
	update_angle = true
	$TimerStart.start(time_to_start)

func _physics_process(delta: float):
	if update_angle == true:
		adjust_angle()
	if moving == true:
		
		var _kinematic_collider: KinematicCollision2D = move_and_collide(velocity * delta)

func _update_velocity() -> void :
	velocity = position.direction_to(
		VarsGlobal.Player.global_position - Vector2(0, 30)
	).normalized() * speed

func adjust_angle():
	if update_angle == true:
		_update_velocity()
		
		var original_angle = velocity.angle()
		
		var adjusted_angle = original_angle + deg2rad(angle_variation)
		
		velocity = Vector2(cos(adjusted_angle), sin(adjusted_angle)) * speed
		
		$FrigusElisia.set_rotation(velocity.angle())

func destroy() -> void :
	sfx_end()
	VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
	Gamepad.start_vibration(0, 0.4, 0.4, 0.5)
	$AnimationPlayer.play("destroy")
	set_physics_process(false)

func sfx_start() -> void :
	Audio.play_sfx("ec_ice_start")
func sfx_end() -> void :
	Audio.play_sfx("ec_ice_end")
	Audio.play_sfx("explosion_light2")
	Audio.play_sfx("impact_mineral")

func _on_TimerStart_timeout() -> void :
	Audio.play_sfx("shine2")
	$AnimationPlayer.play("prechase")
	yield($AnimationPlayer, "animation_finished")
	update_angle = false
	moving = true

func _on_AreaDetectFloor_body_entered(_body: Node) -> void :
	destroy()
