extends KinematicBody2D

var velocity: = Vector2()

var gravity: int = 500

var speed: int = 70

var _patrol: bool = true

var _dashing: bool = false

onready var Enemy = $EnemyBase
onready var AreaNoFloor = $Sprite / DetectNoFloor
onready var AreaPlayerFront = $Sprite / AreaPlayerFront
onready var CollisionAtk = $Sprite / HitboxArm / CollisionAtk

func _ready() -> void :
	Enemy.change_state("walk", true)

func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if Enemy.state in ["idle", "dead"]:
		velocity.x = 0
	
	if Enemy.state == "attack":
		if _dashing == true:
			velocity.x = (speed * 3) * Enemy.facing
		else:
			velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN * 8, Vector2.UP, true)
	
	
	if (
		(is_on_floor() and Enemy.state == "walk")
		and (is_on_wall() or AreaNoFloor.is_colliding() == false)
	):
		Enemy.change_direction("inverse")
	
	if Enemy.state == "attack" and is_on_wall():
		return_to_patrol()
		Enemy.change_direction("inverse")

func set_dashing(val: bool) -> void :
	_dashing = val

func play_snd(audio: String) -> void :
	Audio.play_sfx(audio)

func make_attack() -> void :
	if Enemy.state != "attack":
		Audio.play_sfx("kryvon_startatk")
		velocity.x = 0
		_patrol = false
		Enemy.change_direction("to_player")
		Enemy.change_state("attack")

func return_to_patrol() -> void :
	CollisionAtk.set_deferred("disabled", true)
	$GhostTrail.stop_trail()
	velocity.x = 0
	_dashing = false
	_patrol = true
	Enemy.change_state("walk")

func jump_atk() -> void :
	velocity.y = - 190
	velocity.x = 100 * Enemy.facing

func _on_TimerChangePatrolState_timeout() -> void :
	
	if AreaPlayerFront.is_colliding() == true and is_on_wall() == false:
		make_attack()
		return
	
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
		rand_range(3, 4)
	)

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")

func _on_AreaPlayerFront_object_entered(_Obj) -> void :
	if Enemy.state in ["walk", "idle"]:
		make_attack()

func _on_HurtboxEnemy_defeated() -> void :
	$GhostTrail.start_trail()

func _on_DetectNoFloor_object_exited(_Obj) -> void :
	pass

