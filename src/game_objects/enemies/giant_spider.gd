extends KinematicBody2D



var VenomCloud = preload("res://src/game_objects/enemies_weapons/venom_cloud.tscn")


var velocity: = Vector2()

var gravity: int = 250

var speed: int = 30

onready var Enemy = $EnemyBase
onready var AreaFrontPlayer = $GiantSpider / AreaFrontPlayer
onready var AreaBackPlayer = $GiantSpider / AreaBackPlayer
onready var Spr = $GiantSpider
onready var PositionAtk = $GiantSpider / Position2D
onready var VisibleNotif = $VisibilityNotifierCameraArea

func _ready() -> void :
	Enemy.change_state("idle", true)

func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if Enemy.state in ["idle", "attack", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if is_on_floor() and Enemy.state == "walk" and is_on_wall():
		Enemy.change_direction("inverse")
	
	if is_on_floor():
		var normal: Vector2 = get_floor_normal()
		var offset: float = deg2rad(90)
		Spr.rotation = normal.angle()
		Spr.rotation = normal.angle() + offset

func _spawn_atk() -> void :
	var dir_atk: int = Enemy.facing
	Audio.play_sfx("floor_slide2")
	var ObjInstance = VenomCloud.instance()
	ObjInstance.dir = dir_atk
	ObjInstance.global_position = PositionAtk.global_position
	ObjInstance.speed = ObjInstance.speed * 2
	ObjInstance.time_active = 2
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _on_DetectNoFloor_object_exited(_Obj) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("inverse")

func _on_TimerPatrol_timeout() -> void :

	randomize()

	if Enemy.state == "dead":
		return
	elif Enemy.state == "attack":
		$TimerPatrol.start(0.5)
		return

	match Enemy.state:
		"idle":
			Enemy.change_state("walk")
		"walk":
			Enemy.change_state("idle")
			if (
				AreaFrontPlayer.is_colliding() == true
				or AreaBackPlayer.is_colliding() == true
			):
				Enemy.change_direction("to_player")
			else:
				Enemy.change_direction(RNGTools.pick(["-1", "1"]))
	
	$TimerPatrol.start(rand_range(2, 3))


func _on_AreaBackPlayer_object_entered(_Obj) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("inverse")

func _on_atk_end() -> void :
	if Enemy.state != "dead":
		randomize()
		$TimerMakeAtk.start(rand_range(3.5, 5))

func _on_TimerMakeAtk_timeout() -> void :
	if Enemy.state in ["idle", "walk"] and VisibleNotif.is_on_screen():
		Enemy.change_state("attack")
	else:
		$TimerMakeAtk.start(0.5)


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")


func _on_HurtboxEnemy_defeated() -> void :
	pass





