extends KinematicBody2D

var velocity: = Vector2()

var gravity: int = 280

var speed: int = 25

onready var Enemy = $EnemyBase
onready var SeePlayer = $Sprite / SeePlayer
onready var DetectPlayerBack = $Sprite / DetectPlayerBack
onready var TimerPatrolWait = $TimerPatrolWait

func _ready() -> void :
	start_patrol()
	
func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing
	elif Enemy.state == "attack":
		velocity.x = (speed * 2.5) * Enemy.facing

	if is_on_floor() and Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	
	if is_on_wall() == true:
		Enemy.change_direction()
		return_to_patrol()

func return_to_patrol() -> void :
	if Enemy.state in ["idle", "walk"] and SeePlayer.is_colliding():
		make_atk()
	elif Enemy.state in ["pre-attack_power", "attack"] and SeePlayer.is_colliding() == false:
		start_patrol()

func start_patrol() -> void :
	
	if Enemy.state == "idle":
		Enemy.change_direction(RNGTools.pick(["1", "-1"]))
		Enemy.change_state("walk")
	else:
		Enemy.change_state("idle")
		
	$Sprite / HitboxEnemy / CollisionKnife.set_deferred("disabled", true)
	randomize()
	TimerPatrolWait.start(rand_range(1, 3))

func make_atk() -> void :
	if Enemy.state in ["idle", "walk"]:
		TimerPatrolWait.stop()
		Enemy.change_direction("to_player")
		velocity.x = 0
		Enemy.change_state("pre-attack_power")

func _on_DetectNoFloor_object_exited(_Obj) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction()
		return_to_patrol()

func _on_SeePlayer_object_entered(_Obj) -> void :
	make_atk()

func _on_VisibilityEnabler2D_screen_exited() -> void :
	return_to_patrol()

func _on_DetectPlayerBack_object_entered(_Obj) -> void :
	if Enemy.state in ["attack", "pre-attack_power"]:
		Enemy.change_state("idle", true)
		yield(get_tree(), "idle_frame")
		return_to_patrol()
		Enemy.change_direction("to_player")

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle", "walk", "attack"]:
		Enemy.change_direction("to_player")

func _on_TimerPatrolWait_timeout() -> void :
	start_patrol()
