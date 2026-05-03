extends KinematicBody2D

var auto_target: bool = false
var target_position: Vector2
var speed: float = 200
var velocity: Vector2
var increase_speed: float = 0

var acceleration: = Vector2.ZERO
var steer_force: float = 0

var _move: bool = false

func _ready() -> void :
	
	Audio.play_sfx("sword_master_shriek2")
	Audio.play_sfx("shine2")
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("loop")

	_move = true

func _physics_process(delta: float):
	
	if _move == false:
		velocity = Vector2.ZERO
		return

	_update_direction(delta)
	speed += increase_speed

func _update_player_target_pos() -> void :
	target_position = VarsGlobal.Player.global_position
	target_position.y -= 30

func _update_direction(_delta: float = 0) -> void :
	if auto_target == true:
		_update_player_target_pos()

	acceleration += _seek()
	
	velocity += acceleration * _delta
	
	velocity = velocity.limit_length(speed)
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



func _on_HurtboxEnemySimple_defeated() -> void :
	_move = false
	$AnimationPlayer.play("destroy")


func _on_VisibilityNotifier2D_screen_exited() -> void :
	if $AnimationPlayer.current_animation == "loop":
		_move = false
		queue_free()
