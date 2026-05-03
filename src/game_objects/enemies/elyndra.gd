extends KinematicBody2D

var Ghost = preload("res://src/game_objects/enemies_weapons/elyndra_ghost.tscn")

var speed: int = 50
var velocity: Vector2

var _target_position: Vector2

onready var Enemy = $EnemyBase
onready var AreaPlayerFront = $Sprite / AreaPlayerFront
onready var TimerPush = $TimerPush
onready var GhostTrail = $GhostTrail

func _ready() -> void :
	Enemy.change_state("idle", true)

func _process(_delta: float) -> void :
	
	if Enemy.state == "idle":
	
		
		velocity = Vector2.ZERO
		
		Enemy.change_direction("to_player")
		
		velocity = _target_position * speed
	
	velocity = move_and_slide(velocity)

func spawn_ghost() -> void :
	var ObjInstance = Ghost.instance()
	ObjInstance.global_position = $Sprite / Position2DGhost.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func snd_woosh() -> void :
	Audio.play_sfx("woosh_attack")

func snd_spawn() -> void :
	Audio.play_sfx("spell_shoot2")

func push_body() -> void :
	randomize()
	
	var direction: = Vector2(0, 0)
	
	var push_speed = 200
	var push_duration = 0.15

	match Enemy.state:
		"attack_a":
			direction = Vector2(Enemy.facing, 1)
		"attack_b":
			direction = Vector2(Enemy.facing, 0)
			push_duration = 0.2
		"attack_c":
			
			if (
				Enemy.get_player_position(Vector2(0, - 32)).y > global_position.y
			):
				direction = Vector2(Enemy.facing, 1)
			else:
				direction = Vector2(Enemy.facing, - 1)
			
			push_duration = 0.2
	
	GhostTrail.start_trail()

	
	var push_velocity = direction.normalized() * push_speed

	push_velocity.y += rand_range( - 30, 30)

	velocity = push_velocity

	
	TimerPush.start(push_duration)
	yield(TimerPush, "timeout")

	
	velocity = Vector2.ZERO
	
	GhostTrail.stop_trail()

func _on_TimerMakeAttack_timeout() -> void :
	randomize()
	
	if AreaPlayerFront.is_colliding() == true:
		velocity = Vector2.ZERO
		Enemy.change_state(
			RNGTools.pick([
				"attack_a", "attack_a", 
				"attack_b", "attack_b", 
				"attack_c"
			])
		)
	
	elif $VisibilityNotifierCameraArea.is_on_screen():
		velocity = Vector2.ZERO
		Enemy.change_state("attack_c")
	
	$TimerMakeAttack.start(
		rand_range(2.5, 4.0)
	)


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state == "idle":
		push_body()


func _on_EnemyBase_state_changed(state) -> void :
	if state == "idle":
		$GhostTrail2.start_trail(0.0, 0.2)
	elif state == "dead":
		GhostTrail.stop_trail()
		$GhostTrail2.stop_trail()


func _on_TimerUpdateChasePos_timeout() -> void :
	_target_position = global_position.direction_to(
		Enemy.get_player_position(Vector2(0, - 40))
	)
