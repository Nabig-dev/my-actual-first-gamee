extends KinematicBody2D

var velocity: = Vector2()

var speed: int = 15

onready var Enemy = $EnemyBase

func _ready() -> void :
	Enemy.change_state("swim")

func _physics_process(_delta: float) -> void :

	if Enemy.state in ["dead"]:
		velocity = Vector2.ZERO
	
	if Enemy.state == "swim":
		velocity.x = speed * Enemy.facing
	
	velocity = move_and_slide(velocity, Vector2.UP, true)

	if is_on_wall():
		if Enemy.state == "swim":
			Enemy.change_direction("inverse")

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state == "swim":
		Enemy.change_direction("to_player")

func _on_VisibilityEnabler2D_screen_entered() -> void :
	Enemy.change_direction("to_player")

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	Enemy.change_direction("to_player")
