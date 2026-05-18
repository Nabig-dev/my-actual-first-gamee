extends KinematicBody2D

var FloorAtk = preload("res://src/game_objects/enemies_weapons/golum_floor_atk.tscn")

var _now_floor_attacks: int
var _max_floor_attacks: int = 6

var velocity: = Vector2()

var gravity: int = 450

var speed: int = 80

onready var Enemy = $EnemyBase
onready var RayCastFloorFront = $Sprite / RayCastFloorFront
onready var TimerChangeDirection = $TimerChangeDirection
onready var TimerIdle = $TimerIdle
onready var AreaSeePlayer = $Sprite / AreaSeePlayer
onready var AreaBackPlayer = $Sprite / AreaBack
onready var VisibNotifier = $VisibilityNotifierCameraArea
onready var TimerSpawnFloorAtk = $TimerSpawnFloorAtk
onready var PositionFloorAtk = $Sprite / PositionFloorAtk

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

func _spawn_floor_atk(reset: bool) -> void :
	if reset == true:
		PositionFloorAtk.position.x = 90
		_now_floor_attacks = 0
		
		VarsGlobal.GameScenario.CameraNode.start_shake(0.6, true, false)
		Gamepad.start_vibration(0, 0.8, 0.8, 0.5)
	
	
	if _now_floor_attacks == _max_floor_attacks:
		_now_floor_attacks = 0
		TimerSpawnFloorAtk.stop()
		return
	
	var floor_atk_instance = FloorAtk.instance()
	floor_atk_instance.connect(
		"stoped", self, "_on_FloorAtk_stoped"
	)
	floor_atk_instance.scale.x = Enemy.facing
	floor_atk_instance.global_position = PositionFloorAtk.global_position
	VarsGlobal.GameScenario.add_child(floor_atk_instance)
	
	PositionFloorAtk.position.x += 32
	_now_floor_attacks += 1

func make_attack() -> void :
	if Enemy.state in ["idle", "walk"]:
		velocity.x = 0
		Enemy.change_direction("to_player")
		Enemy.change_state(
			RNGTools.pick([
				"attack_a", 
				"attack_b", 
				"attack_c"
			])
		)

func _wosh() -> void :
	Audio.play_sfx("woosh_whip_m")

func _shake_impact() -> void :
	Audio.play_sfx("explosion_light")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
	Gamepad.start_vibration(0, 0.4, 0.4, 0.5)

func _on_TimerChangeDirection_timeout() -> void :
	randomize()
	
	if Enemy.state == "walk":
		if AreaSeePlayer.is_colliding() == true:
			Enemy.change_direction("to_player")
		else:
			Enemy.change_direction(RNGTools.pick(["1", "-1"]))
		Enemy.change_state("idle")
	
	TimerIdle.start(rand_range(1, 2.5))
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

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state == "idle":
		Enemy.change_direction("to_player")
	elif Enemy.state == "walk" and AreaSeePlayer.is_colliding() == true:
		make_attack()

func _on_TimerSpawnFloorAtk_timeout() -> void :
	_spawn_floor_atk(false)

func _on_HurtboxEnemy_defeated() -> void :
	TimerSpawnFloorAtk.stop()

func _on_FloorAtk_stoped() -> void :
	_now_floor_attacks = _max_floor_attacks
