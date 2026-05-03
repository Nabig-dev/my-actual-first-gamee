extends KinematicBody2D

export var active: bool = true

var speed: int = 300
var velocity: Vector2

var _is_chasing: bool

var _last_player_pos: Vector2

onready var Enemy = $EnemyBase
onready var Tw = $Tween
onready var TimerRepeatAtk = $TimerRepeatAtk
onready var VisibNotifier = $VisibilityNotifierCameraArea

func _physics_process(_delta: float) -> void :
	
	if Enemy.state in ["dead"] or VisibNotifier.is_on_screen() == false:
		return
	
	if _is_chasing == true:
		Enemy.change_direction("to_player")
		velocity = Vector2.ZERO
		velocity = global_position.direction_to(
			_last_player_pos
		) * speed
		
		if global_position.distance_to(_last_player_pos) < 10:
			set_chase(false)
			Enemy.change_state("fly")
			return
	else:
		velocity.x = lerp(velocity.x, 0, 0.5)

	velocity = move_and_slide(velocity)

func move_to_rand_pos() -> void :

	if Enemy.state in ["sleep", "dead"]:
		return

	randomize()

	
	var distance_x: float = global_position.x + rand_range( - 100, 100)
	var player_pos_y: float = Enemy.get_player_position(Vector2(
		0, rand_range( - 50, - 100)
	)).y
	
	var _pos_to_fly: = Vector2(distance_x, player_pos_y)

	Tw.remove_all()
	Tw.stop_all()
	
	Tw.interpolate_property(
		self, 
		"global_position", 
		global_position, 
		_pos_to_fly, 
		rand_range(1, 2), Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	
	Tw.start()
	
	yield(Tw, "tween_completed")
	Enemy.change_direction("to_player")

func _breath_snd() -> void :
	Audio.play_sfx("ec_shoot2")

func set_chase(val: bool) -> void :
	_is_chasing = val
	if val == true:
		velocity = Vector2.ZERO
		Enemy.change_direction("to_player")
		_last_player_pos = Enemy.get_player_position(Vector2(0, - 30))
	else:
		velocity = Vector2.ZERO
		Enemy.change_direction("to_player")

func _check_timer_atk() -> void :
	if TimerRepeatAtk.is_stopped() == true:
		_on_EnemyBase_state_changed("fly")

func _on_EnemyBase_state_changed(state: String) -> void :
	if state == "fly":
		randomize()
		Enemy.change_direction("to_player")
		TimerRepeatAtk.start(rand_range(2, 4))
	elif state == "attack":
		Enemy.change_direction("to_player")


func _on_TimerRepeatAtk_timeout() -> void :

	if Enemy.state == "fly" and VisibNotifier.is_on_screen():
		Enemy.change_direction("to_player")
		velocity = Vector2.ZERO
		Tw.remove_all()
		Tw.stop_all()
		Enemy.change_state("attack")
	elif Enemy.state == "attack":
		TimerRepeatAtk.start(3)


func _on_TimerRepeatMove_timeout() -> void :
	if Enemy.state == "fly" and _is_chasing == false:
		velocity = Vector2.ZERO
		Enemy.change_direction("to_player")
		move_to_rand_pos()


func _on_EnemyBase_enemy_defeated(_NodeEnemy) -> void :
	_is_chasing = false
	velocity = Vector2.ZERO
	Tw.remove_all()
	Tw.stop_all()
	TimerRepeatAtk.stop()
	$TimerRepeatMove.stop()


func _on_TimerStart_timeout() -> void :
	Enemy.change_state("fly", true)
