extends KinematicBody2D


var velocity: = Vector2()

var speed: int = 40

onready var Enemy = $EnemyBase

func _ready() -> void :
	Enemy.change_state("swim")

func _physics_process(_delta: float) -> void :

	if Enemy.state in ["dead"]:
		velocity = Vector2.ZERO
	
	if Enemy.state == "swim":
		velocity.y = 0
		velocity.x = speed * Enemy.facing
	elif Enemy.state == "chase":
		velocity = Vector2.ZERO
		Enemy.change_direction("to_player")
		velocity = global_position.direction_to(
			Enemy.get_player_position(Vector2(0, - 30))
		) * speed
		velocity.x = (speed * 1.2) * Enemy.facing
	
	velocity = move_and_slide(velocity, Vector2.UP, true)

	if is_on_wall() or is_on_floor() or is_on_ceiling():
		if Enemy.state == "swim":
			Enemy.change_direction("inverse")
		if Enemy.state == "chase":
			Enemy.change_state("swim")

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["swim", "chase"]:
		Enemy.change_direction("to_player")


func _on_Area2DDetectPlayer_area_entered(_area: Area2D) -> void :
	if Enemy.state in ["swim"]:
		Enemy.change_state("chase")

func _on_Area2DDetectPlayer_area_exited(_area: Area2D) -> void :
	if Enemy.state in ["chase"]:
		Enemy.change_state("swim")


func _on_VisibilityEnabler2D_screen_entered() -> void :
	Enemy.change_direction("to_player")
