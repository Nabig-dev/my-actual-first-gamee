extends KinematicBody2D


var velocity: = Vector2()

var speed: int = 50

var gravity: int = 20

onready var Enemy = $EnemyBase

func _ready() -> void :
	Enemy.change_state("swim")

func _physics_process(delta: float) -> void :
	
	if Enemy.state in ["dead"]:
		velocity = Vector2.ZERO
	
	if Enemy.state == "swim" and velocity.y < 0:
		velocity.x = speed * Enemy.facing
	
	elif Enemy.state == "swim" and velocity.y >= 0:
		velocity.x = lerp(velocity.x, 0, 0.1)
	
	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)

func swim() -> void :
	Enemy.change_direction("to_player")
	if Enemy.is_player_up():
		velocity.y = - 50
	else:
		velocity.y = - 20


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state != "dead":
		Enemy.change_direction("to_player")
