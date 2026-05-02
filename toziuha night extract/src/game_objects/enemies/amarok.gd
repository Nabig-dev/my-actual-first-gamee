extends KinematicBody2D


var velocity: = Vector2()

var gravity: int = 450

var speed: int = 180

onready var Enemy = $EnemyBase
onready var RayCastFloorFront = $Sprite / RayCastFloorFront
onready var AreaSeePlayer = $Sprite / AreaSeePlayer


func _ready() -> void :
	Enemy.change_state("idle", true)


func _physics_process(delta: float) -> void :
		
	if Enemy.state == "run":
		velocity.x = speed * Enemy.facing
		if RayCastFloorFront.is_colliding() == false:
			Enemy.change_state("jump")

	if is_on_floor() and Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	
	if is_on_wall():
		Enemy.change_direction()

func jump() -> void :
	velocity.y -= 150

func _on_AreaSeePlayer_object_entered(_Obj) -> void :
	if $VisibilityNotifier2D.is_on_screen():
		Audio.play_sfx("roar_hound")
		Enemy.change_direction("to_player")
		Enemy.change_state("run")

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state == "idle":
		Enemy.change_direction("to_player")


func _on_VisibilityNotifier2D_screen_entered() -> void :
	if Enemy.state == "idle":
		Enemy.change_direction("to_player")


func _on_TimerCheckSeePlayerStart_timeout() -> void :
	if Enemy.state == "idle" and AreaSeePlayer.is_colliding():
		_on_AreaSeePlayer_object_entered(null)
