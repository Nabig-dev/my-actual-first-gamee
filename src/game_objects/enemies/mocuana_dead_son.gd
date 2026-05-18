extends KinematicBody2D






var speed: float = 50
var velocity: Vector2

var _is_chasing: bool

onready var Enemy = $EnemyBase

func _ready() -> void :
	randomize()
	$AnimationPlayer.play("appear")
	speed = rand_range(50, 90)

func _physics_process(_delta: float) -> void :
	
	if Enemy.state in ["dead"]:
		return
	
	if _is_chasing == true and Enemy.state == "fly":
		velocity = Vector2.ZERO
		velocity = global_position.direction_to(
			Enemy.get_player_position() - Vector2(0, 30)
		) * speed

	velocity = move_and_slide(velocity)

func _on_TimerActive_timeout() -> void :
	_is_chasing = true
	Enemy.change_state("fly")


func _on_TimerAutoDead_timeout() -> void :
	Enemy.change_state("dead")
