extends KinematicBody2D



var Bullet = preload("res://src/game_objects/enemies_weapons/feather_crown.tscn")
var Explosion = preload("res://src/game_objects/enemies_weapons/bomb_a_explosion.tscn")


var velocity: = Vector2()

var gravity: int = 250

var speed: int = 70

onready var Enemy = $EnemyBase
onready var TimerPatrol = $TimerPatrol
onready var AreaSeePlayer = $Sprite / AreaSeePlayer

func _ready() -> void :
	Enemy.change_state("walk")

func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if is_on_floor() and Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	
	if (
		(is_on_wall())
		
	):
		Enemy.change_direction()

func shoot() -> void :
	var ObjInstance = Explosion.instance()
	ObjInstance.global_position = $Sprite / Position2DWeapon.global_position
	ObjInstance.scale = Vector2(0.8, 0.8)
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
	ObjInstance = Bullet.instance()
	ObjInstance.auto_target = false
	ObjInstance.global_position = $Sprite / Position2DWeapon.global_position
	ObjInstance.scale = Vector2(0.5, 0.5)
	ObjInstance.target_position = $Sprite / Position2DWeaponShoot.global_position
	ObjInstance.speed = 900
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	

func return_to_patrol() -> void :
	randomize()
	if Enemy.state == "walk":
		TimerPatrol.start(rand_range(0.5, 1.5))
		Enemy.change_state("idle")
	elif Enemy.state == "idle":
		TimerPatrol.start(rand_range(2, 3))
		Enemy.change_direction(RNGTools.pick(["-1", "1"]))
		Enemy.change_state("walk")

func _on_TimerPatrol_timeout() -> void :

	var new_atk: String = RNGTools.pick(["whip", "shoot"])

	if AreaSeePlayer.is_colliding() == true and new_atk != Enemy.prev_state:
		velocity.x = 0
		Enemy.change_state(
			new_atk
		)
		TimerPatrol.start(3)
	else:
		TimerPatrol.stop()
		return_to_patrol()


func _on_EnemyBase_enemy_defeated(_NodeEnemy) -> void :
	velocity.x = 0
	TimerPatrol.stop()
