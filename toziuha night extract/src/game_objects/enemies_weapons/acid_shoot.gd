extends KinematicBody2D

var skip_show_anim: bool = false
var auto_target: bool = true
var collide: bool = true

var target_position: Vector2
var speed: float = 600
var velocity: Vector2

var acceleration: = Vector2.ZERO
var steer_force: float = 100

var _move: bool = false

func _ready() -> void :
	
	if auto_target == true:
		speed = 50
		_update_player_target_pos()
		
		create_tween().tween_property(
			self, "speed", 800, 2
		)
		steer_force = 200
		
		create_tween().tween_property(
			self, "steer_force", 0, 1
		)

	Audio.play_sfx("spell_prepare2")
	
	if skip_show_anim == false:
		$AnimationPlayer.play("show")
		yield($AnimationPlayer, "animation_finished")
	
	else:
		_start_move()
	
	$AnimationPlayer.play("loop")

func _start_move() -> void :
	if collide == true:
		$AreaDetectSolid / CollisionShape2D.set_deferred("disabled", false)
	$GhostTrail.start_trail(0.5, 0.1)
	Audio.play_sfx("spell_shoot")
	_move = true

func _physics_process(delta: float):
	
	if _move == false:
		velocity = Vector2.ZERO
		return

	_update_direction(delta)

func _update_player_target_pos() -> void :
	target_position = VarsGlobal.Player.global_position
	target_position.y -= 30

func _update_direction(_delta: float = 0) -> void :
	if auto_target == true:
		_update_player_target_pos()

	acceleration += _seek()
	
	velocity += acceleration * _delta
	
	velocity = velocity.clamped(speed)
	rotation = velocity.angle()
	global_position += velocity * _delta
	
func _seek() -> Vector2:
	var _speed: = speed
	var _steer = Vector2.ZERO
	
	if auto_target == false:
		_speed = speed * 100
	
	var desired = (target_position - global_position).normalized() * _speed
	if auto_target == true:
		_steer = (desired - velocity).normalized() * steer_force
	else:
		_steer = (desired - velocity).normalized() * 30
	return _steer

func _on_VisibilityNotifier2D_screen_exited() -> void :
	if collide == false:
		queue_free()

func _on_AreaDetectSolid_object_entered(_Obj) -> void :
	velocity = Vector2.ZERO
	$GhostTrail.stop_trail()
	_move = false
	set_physics_process(false)
	$AnimationPlayer.play("impact")
