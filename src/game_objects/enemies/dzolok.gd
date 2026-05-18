extends KinematicBody2D


var velocity: = Vector2()

var gravity: int = 250

var speed: int = 25

onready var Enemy = $EnemyBase

onready var RayCastFloorFront = $Sprite / RayCastFloorFront

onready var RayCastSeePlayer = $Sprite / RayCastSeePlayer
onready var RayCastNearPlayerFront = $Sprite / RayCastNearPlayerFront
onready var RayCastNearPlayerBack = $Sprite / RayCastNearPlayerBack

onready var TimerWalkToIdle = $TimerWalkToIdle
onready var TimerIdleToWalk = $TimerIdleToWalk



func _ready() -> void :
	randomize()
	TimerWalkToIdle.start(randi() % 2 + 1)
	Enemy.change_state("walk")
	
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

func _dash() -> void :
	velocity.x = 125 * Enemy.facing

func _stop_dash() -> void :
	velocity.x = 0

func _whoosh_sfx() -> void :
	Audio.play_sfx("woosh_knife")


func _on_HurtboxEnemy_damaged() -> void :
	if (
		Enemy.state in ["walk", "idle"] and 
		(RayCastNearPlayerFront.is_colliding() or RayCastNearPlayerBack.is_colliding())
	):
		Enemy.change_direction("to_player")
		Enemy.change_state("attack")

func _on_TimerWalkToIdle_timeout() -> void :
	randomize()
	if RayCastNearPlayerFront.is_colliding():
		Enemy.change_state("attack")
	elif Enemy.state != "attack":
		Enemy.change_state("idle")
	TimerIdleToWalk.start(randi() % 2 + 1)

func _on_TimerIdleToWalk_timeout() -> void :
	randomize()
	
	if RayCastNearPlayerFront.is_colliding():
		Enemy.change_state("attack")
	
	
	elif RayCastSeePlayer.is_colliding() == false:
		
		Enemy.change_direction(RNGTools.pick(["-1", "1"]))
	
	else:
		Enemy.change_direction("to_player")
	
	TimerWalkToIdle.start(randi() % 6 + 1)
	
	if Enemy.state != "attack":
		Enemy.change_state("walk")


func _on_AreaDetectPlayerForPunch_body_entered(_body: Node) -> void :
	Enemy.change_state("attack")
