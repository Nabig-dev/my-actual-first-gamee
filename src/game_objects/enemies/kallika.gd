extends KinematicBody2D

var HandKallika = preload("res://src/game_objects/enemies_weapons/hand_kallika.tscn")

var velocity: = Vector2()

var gravity: int = 280

var speed: int = 50

onready var Enemy = $EnemyBase
onready var RayCastFloorFront = $Sprite / RayCastFloorFront
onready var TimerChangeDirection = $TimerChangeDirection
onready var TimerIdle = $TimerIdle
onready var AreaSeePlayer = $Sprite / AreaSeePlayer
onready var VisibNotifier = $VisibilityNotifierCameraArea

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
		and Enemy.state != "attack"
		and Enemy.state != "magic_a"
	):
		Enemy.change_direction()

func make_attack() -> void :
	if Enemy.state in ["idle", "walk"]:
		Audio.play_sfx("kryvon_startatk")
		velocity.x = 0
		Enemy.change_direction("to_player")
		Enemy.change_state("attack")

func make_magic() -> void :
	if Enemy.state in ["idle", "walk"]:
		Audio.play_sfx("kryvon_startatk")
		velocity.x = 0
		Enemy.change_direction("to_player")
		Enemy.change_state("magic_a")

func _snd_prepare() -> void :
	Audio.play_sfx("spell_prepare3")
	
func _snd_slash() -> void :
	Audio.play_sfx("shoot_projectile2")

func _spawn_magic_a() -> void :
	var ObjInstance = HandKallika.instance()
	ObjInstance.global_position = Enemy.get_player_position(Vector2(0, - 30))
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _on_TimerChangeDirection_timeout() -> void :
	randomize()
	
	if Enemy.state == "walk":
		Enemy.change_direction(RNGTools.pick(["1", "-1"]))
		Enemy.change_state("idle")
	
	TimerIdle.start(rand_range(1, 2.5))
	yield(TimerIdle, "timeout")
	
	TimerChangeDirection.start(rand_range(3, 5))
	
	if randi() % 2 == 1 and VisibNotifier.is_on_screen() == true:
			make_magic()
	elif AreaSeePlayer.is_colliding():
		make_attack()
	elif Enemy.state == "idle":
		Enemy.change_direction("to_player")
		Enemy.change_state("walk")
	

func _on_AreaSeePlayer_object_entered(_Obj) -> void :
	randomize()
	if randi() % 2 == 1:
			make_magic()
	else:
		make_attack()

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
	elif Enemy.state == "walk" and AreaSeePlayer.is_colliding() == true:
		make_attack()

func _on_AreaBack_object_entered(_Obj) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
