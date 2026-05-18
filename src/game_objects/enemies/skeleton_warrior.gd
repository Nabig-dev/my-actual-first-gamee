extends KinematicBody2D

export var only_shield: bool


var velocity: = Vector2()

var gravity: int = 250

var speed: int = 50


var _original_def: int = 0

onready var Enemy = $EnemyBase

onready var RayCastFloorFront = $Sprite / RayCastFloorFront

onready var RayCastSeePlayer = $Sprite / RayCastSeePlayer
onready var RayCastNearPlayerFront = $Sprite / RayCastNearPlayerFront
onready var RayCastNearPlayerFront2 = $Sprite / RayCastNearPlayerFront2
onready var RayCastNearPlayerBack = $Sprite / RayCastNearPlayerBack

onready var TimerWalkToIdle = $TimerWalkToIdle
onready var TimerIdleToWalk = $TimerIdleToWalk

onready var HurtboxEnemy = $HurtboxEnemy

func _ready() -> void :
	
	if only_shield == true:
		$Sprite.texture = load("res://assets/sprites/enemies/skeleton_shield.png")
		
		
		
	
	randomize()
	TimerWalkToIdle.start(randi() % 2 + 1)
	Enemy.change_state("walk")
	
	_original_def = HurtboxEnemy.def
	
func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if is_on_floor() and Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	
	if (
		(is_on_wall() or RayCastFloorFront.is_colliding() == false)
		and Enemy.state != "attack"
	):
		Enemy.change_direction()
	
	
	if (
		Input.is_action_just_pressed("attack")
		and global_position.distance_to(VarsGlobal.Player.global_position) < 64
		and Enemy.state != "attack"
	):
		if RayCastNearPlayerFront.is_colliding() or RayCastNearPlayerFront2.is_colliding():
			velocity.x = 0
			HurtboxEnemy.def = HurtboxEnemy.def * 4
			TimerIdleToWalk.stop()
			TimerWalkToIdle.stop()
			
			if only_shield == true:
				Enemy.change_state("idle", true)
			Enemy.change_state("defend", true)
			HurtboxEnemy.damage_sounds[0] = "impact_shield_clang"
		else:
			HurtboxEnemy.damage_sounds[0] = "enemy_damage_skeleton"
			HurtboxEnemy.def = _original_def

func _whoosh_sfx() -> void :
	Audio.play_sfx("woosh_knife")


func _stop_defend() -> void :
	HurtboxEnemy.damage_sounds[0] = "enemy_damage_skeleton"
	HurtboxEnemy.def = _original_def
	
	Enemy.change_state("idle")
	TimerIdleToWalk.start(1)


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["walk", "idle"]:
		Enemy.change_direction("to_player")
		velocity.x = 0
		Enemy.change_state("attack")

func _on_TimerWalkToIdle_timeout() -> void :
	randomize()
	if RayCastNearPlayerFront.is_colliding():
		velocity.x = 0
		Enemy.change_state("attack")
	elif Enemy.state != "attack":
		Enemy.change_state("idle")
	TimerIdleToWalk.start(randi() % 2 + 1)

func _on_TimerIdleToWalk_timeout() -> void :
	randomize()
	
	if RayCastNearPlayerFront.is_colliding():
		velocity.x = 0
		Enemy.change_state("attack")
	
	
	elif RayCastSeePlayer.is_colliding() == false and Enemy.state != "attack":
		
		
		Enemy.change_direction(RNGTools.pick(["-1", "1"]))
	
	elif Enemy.state != "attack":
		Enemy.change_direction("to_player")
	
	TimerWalkToIdle.start(randi() % 6 + 1)
	
	if Enemy.state != "attack":
		Enemy.change_state("walk")


func _on_AreaDetectPlayerForPunch_body_entered(_body: Node) -> void :
	if Enemy.state != "defend":
		velocity.x = 0
		Enemy.change_state("attack")


func _on_EnemyBase_state_changed(state) -> void :
	if state == "attack" and only_shield == true:
		Enemy.change_state("walk")
		TimerWalkToIdle.start(randi() % 6 + 1)
