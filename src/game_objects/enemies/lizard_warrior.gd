extends KinematicBody2D




var velocity: = Vector2()

var gravity: int = 450

var speed: int = 60

onready var Enemy = $EnemyBase
onready var RayCastFloorFront = $Sprite / RayCastFloorFront
onready var TimerChangeDirection = $TimerChangeDirection
onready var TimerIdle = $TimerIdle
onready var AreaSeePlayer = $Sprite / AreaSeePlayer
onready var AreaBackPlayer = $Sprite / AreaBack
onready var VisibNotifier = $VisibilityNotifierCameraArea
onready var TimeDash = $TimeDash

func _ready() -> void :
	Enemy.change_state("walk")

func _physics_process(delta: float) -> void :
		
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if is_on_floor() and Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	
	if (
		(is_on_wall() or RayCastFloorFront.is_colliding() == false)
		and Enemy.state != "attack_a"
		and Enemy.state != "attack_b"
		and Enemy.state != "attack_c"
	):
		Enemy.change_direction()

func _grunt() -> void :
	Audio.play_sfx("kryvon_startatk")
func _slash() -> void :
	Audio.play_sfx("sword_slash_slow2")

func dash(time: float = 1, speed_dash: float = 450) -> void :
	
	if TimeDash.is_stopped() == false:
		return
	
	TimeDash.start(time)
	velocity.x = speed_dash * Enemy.facing
	yield(TimeDash, "timeout")
	velocity.x = 0

func jump() -> void :
	velocity.y -= 200

func make_attack() -> void :
	if Enemy.state in ["idle", "walk"] and $TimerAttackCoolDown.is_stopped():
		
		$TimerAttackCoolDown.start(1)
		
		var distance_to_player: float = Enemy.get_player_distance()
		
		velocity.x = 0
		Enemy.change_direction("to_player")
		
		if distance_to_player < 100:
			Enemy.change_state("attack_a")
		else:
			Enemy.change_state("attack_b")

func _on_TimerChangeDirection_timeout() -> void :
	randomize()
	
	if Enemy.state == "walk":
		if (
			AreaSeePlayer.is_colliding() == true
			or AreaBackPlayer.is_colliding() == true
		):
			Enemy.change_direction("to_player")
		else:
			Enemy.change_direction(RNGTools.pick(["1", "-1"]))
		Enemy.change_state("idle")
	
	TimerIdle.start(rand_range(1, 2))
	yield(TimerIdle, "timeout")
	
	TimerChangeDirection.start(rand_range(4, 7))
	
	if (
		AreaSeePlayer.is_colliding() == true
		or AreaBackPlayer.is_colliding() == true
	):
		make_attack()
	elif Enemy.state == "idle":
		Enemy.change_state("walk")


func _on_AreaSeePlayer_object_entered(_Obj) -> void :
	make_attack()

func _on_AreaBack_object_entered(_Obj) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")


func _on_EnemyBase_enemy_defeated(_NodeEnemy) -> void :
	velocity.x = 0
	$GhostTrail.stop_trail()


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
	if Enemy.state == "walk" and AreaSeePlayer.is_colliding() == true:
		make_attack()
