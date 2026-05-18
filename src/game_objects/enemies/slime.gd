extends KinematicBody2D

export var appear_anim: bool

onready var Enemy = $EnemyBase
onready var RayCast2DNoFloor = $Sprite / RayCast2DNoFloor

var velocity: = Vector2()

var gravity: int = 250

var speed: int = 20

func _ready() -> void :
	if appear_anim == true:
		Enemy.change_state("appear", true)
	else:
		Enemy.change_state("walk", true)
	
func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if (is_on_floor() and Enemy.state == "walk") and (is_on_wall() or RayCast2DNoFloor.is_colliding() == false):
		Enemy.change_direction("inverse")

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")

func _on_VisibilityEnabler2D_screen_entered() -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")

func _on_Area2DDetectPlayer_area_entered(_area: Area2D) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
