extends KinematicBody2D

var speed: int = 100
var velocity: Vector2

var _target_position: Vector2

onready var Enemy = $EnemyBase

func _ready() -> void :
	$AnimationPlayer.play("idle")
	_on_TimerUpdateChase_timeout()
	$GhostTrail.start_trail(0.0, 0.1)

func _process(_delta: float) -> void :
	
	var direction = (_target_position - global_position).normalized()
	
	velocity = direction * speed
	
	velocity = move_and_slide(velocity)

	if global_position.distance_to(_target_position) < 40:
		_on_HurtboxEnemy_defeated()

func _on_TimerUpdateChase_timeout() -> void :
	_target_position = Enemy.get_player_position(Vector2(0, - 35))
	Enemy.change_direction("to_player")

func _on_TimerAutoDestroy_timeout() -> void :
	_on_HurtboxEnemy_defeated()

func _on_HurtboxEnemy_defeated() -> void :
	set_physics_process(false)
	velocity = Vector2.ZERO
	$HitboxEnemy.set_deferred("monitorable", false)
	$AnimationPlayer.play("destroy")
