extends KinematicBody2D


var velocity: = Vector2()

var gravity: int = 300

var speed: int = 80

onready var Enemy = $EnemyBase
onready var AreaNoFloor = $SkullSpider / DetectNoFloor

func _ready() -> void :
	Enemy.change_state("walk", true)

func _physics_process(delta: float) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if Enemy.state in ["dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN * 8, Vector2.UP, true)
	
	if is_on_floor() and Enemy.state == "walk" and is_on_wall():
		Enemy.change_direction("inverse")


func _on_DetectNoFloor_object_exited(_Obj) -> void :
	if Enemy.state != "dead":
		Enemy.change_direction("inverse")


func _on_VisibilityNotifier2D_screen_exited() -> void :
	if AreaNoFloor.is_colliding() == true and Enemy.state != "dead":
		Enemy.change_direction("to_player")
