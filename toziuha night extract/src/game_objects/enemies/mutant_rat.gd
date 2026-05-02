extends KinematicBody2D


var velocity: = Vector2()

var gravity: int = 350

var speed: int = 100

var _patrol: bool = true

onready var Enemy = $EnemyBase
onready var AreNoFloor = $Sprite / DetectNoFloor
onready var AreaPlayerFront = $Sprite / AreaPlayerFront


func _ready() -> void :
	Enemy.change_state("walk", true)

func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if Enemy.state == "run":
		velocity.x = (speed * 1.5) * Enemy.facing

	if Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if (
		(is_on_floor() and Enemy.state in ["walk", "run"])
		and (is_on_wall() or AreNoFloor.is_colliding() == false)
	):
		Enemy.change_direction("inverse")

func make_attack() -> void :
	randomize()
	Enemy.change_direction("to_player")
	_patrol = false
	Audio.play_sfx("rat")
	
	if Enemy.get_player_distance() <= 65:
		Enemy.change_state("jump")

	else:
		Enemy.change_state("run")

func return_to_patrol() -> void :
	if $Sprite / AreaFrontWall.is_colliding() == true:
		Enemy.change_direction("inverse")
	
	_patrol = true
	Enemy.change_state("idle")
	$TimerChangePatrolState.start(1)

func jump_atk(vel: = Vector2(180, - 170)) -> void :
	
	velocity.y = vel.y
	velocity.x = vel.x * Enemy.facing

func _on_TimerChangePatrolState_timeout() -> void :
	
	if AreaPlayerFront.is_colliding() == true:
		make_attack()
		return
	
	elif Enemy.state == "run":
		_patrol = true
		Enemy.change_state("walk")
	
	randomize()
	
	if _patrol == true:
		if Enemy.state == "idle":
			Enemy.change_state("walk")
		elif Enemy.state == "walk":
			Enemy.change_direction(
				RNGTools.pick(["1", "-1"])
			)
			Enemy.change_state("idle")
	
	$TimerChangePatrolState.start(
		rand_range(2, 4)
	)



func _on_AreaPlayerFront_object_entered(_Obj) -> void :
	if Enemy.state in ["walk", "idle"]:
		make_attack()






func _on_AreaPlayerJump_object_entered(_Obj) -> void :
	if Enemy.state in ["idle", "run", "walk"]:
		_patrol = false
		if Enemy.state == "run":
			velocity.x = velocity.x / 2
		else:
			velocity.x = 0
		make_attack()


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
