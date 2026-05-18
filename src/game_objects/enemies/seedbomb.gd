extends KinematicBody2D

var Explosion = preload("res://src/game_objects/enemies_weapons/explosion_molotov.tscn")
var VenomCloud = preload("res://src/game_objects/enemies_weapons/venom_cloud.tscn")

export var inverted_gravity: bool

var velocity: = Vector2()

var gravity: int = 350

var speed: int = 80

var direction_up: Vector2 = Vector2.UP

onready var Enemy = $EnemyBase
onready var TimerPatrol = $TimerPatrol
onready var RayCast2DNoFloor = $Sprite / RayCast2DNoFloor

func _ready() -> void :
	Enemy.change_state("walk", true)
	TimerPatrol.start(2)
	if inverted_gravity == true:
		invert_gravity()

func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if Enemy.state in ["idle", "dead", "explosion"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, direction_up, true)
	
	if (is_on_floor() and Enemy.state == "walk") and (is_on_wall() or RayCast2DNoFloor.is_colliding() == false):
		Enemy.change_direction("inverse")

func play_snd() -> void :
	Audio.play_sfx("explosion_light3")

func spawn_explosion() -> void :
	var dir_atk: int = Enemy.facing
	var ObjInstance = Explosion.instance()
	ObjInstance.global_position = global_position
	ObjInstance.fire_instance = false
	VarsGlobal.GameScenario.add_child(ObjInstance)
	
	ObjInstance = VenomCloud.instance()
	ObjInstance.global_position = global_position
	ObjInstance.dir = dir_atk
	VarsGlobal.GameScenario.add_child(ObjInstance)
	

func invert_gravity() -> void :
	velocity = Vector2.ZERO
	if $Sprite.scale.y == 1:
		inverted_gravity = true
		direction_up = Vector2.DOWN
	else:
		inverted_gravity = false
		direction_up = Vector2.UP
	$Sprite.scale.y = $Sprite.scale.y * - 1
	gravity = gravity * - 1

func _on_Area2DDetectPlayer_area_entered(_area: Area2D) -> void :
	$TimerStartExplosion.start()
	if inverted_gravity == false:
		
		Enemy.change_direction("to_player")

func _on_TimerPatrol_timeout() -> void :
	randomize()
	
	TimerPatrol.start(
		rand_range(2.0, 3.0)
	)
	
	match Enemy.state:
		"idle":
			Enemy.change_state("walk")
		"walk":
			Enemy.change_state("idle")

	Enemy.change_direction(RNGTools.pick(["-1", "1"]))

func _on_Area2DDetectPlayerUp_area_entered(_area: Area2D) -> void :
	if inverted_gravity == true:
		Enemy.change_direction("to_player")
		invert_gravity()

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state == "dead":
		return
	randomize()
	if randi() % 4 == 0 and inverted_gravity == true:
		Enemy.change_direction("to_player")
		invert_gravity()

func _on_TimerStartExplosion_timeout() -> void :
	if $Sprite / Area2DDetectPlayer.is_colliding() == true:
		Enemy.change_state("explosion")
		Enemy.state = "dead"

func _on_HurtboxEnemy_defeated() -> void :
	Enemy.change_state("explosion")
	Enemy.state = "dead"
