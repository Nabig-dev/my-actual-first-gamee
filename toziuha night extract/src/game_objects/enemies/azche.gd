extends KinematicBody2D

var Sting = preload("res://src/game_objects/enemies_weapons/azche_sting.tscn")

var speed: int = 3500

var gravity: int = 0

var velocity: = Vector2.ZERO

var chasing: bool = false

onready var Enemy = $EnemyBase
onready var VisibilityNode = $VisibilityNotifierCameraArea
onready var GhostTrail = $GhostTrail
onready var TimerPush = $TimerPush


func _ready() -> void :
	Enemy.change_state("fly")

func _physics_process(delta) -> void :
	if (
		Enemy.state == "fly"
		and chasing == true
		and VisibilityNode.is_on_screen()
		and TimerPush.is_stopped()
	):
		velocity = Vector2.ZERO
		Enemy.change_direction("to_player")
		velocity = (
			delta * 
			(global_position.direction_to(
				Enemy.get_player_position(Vector2(0, - 32))
			) * speed)
		)
	elif Enemy.state != "dead" and TimerPush.is_stopped():
		velocity = Vector2.ZERO
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity)

func _on_VisibilityNotifierCameraArea_screen_entered() -> void :
	if $BuzzAudio.is_playing() == false:
		$BuzzAudio.play()
	chasing = true
	randomize()
	$TimerRandomSting.start(rand_range(2, 4))

func _on_HurtboxEnemy_defeated() -> void :
	$BuzzAudio.stop()
	chasing = false
	gravity = 200
	GhostTrail.start_trail()
	velocity.y -= 50
	TimerPush.stop()

func push_body(direction: Vector2) -> void :
	randomize()
	
	
	var push_speed = 100
	var push_duration = 0.5

	
	var push_velocity = direction.normalized() * push_speed

	push_velocity.y += rand_range( - 100, 100)

	velocity = push_velocity

	
	TimerPush.start(push_duration)
	yield(TimerPush, "timeout")
	
	if Enemy.state != "dead":
		
		velocity = Vector2.ZERO

func throw_sting() -> void :
	if VisibilityNode.is_on_screen() == false:
		return
	var StingInstance = Sting.instance()
	StingInstance.global_position = $Sprite / Shine.global_position
	VarsGlobal.GameScenario.add_child(StingInstance)

func _on_HurtboxEnemy_area_entered(area: Area2D) -> void :
	if Enemy.state != "fly" or Enemy.state == "dead":
		return
	var vector_opposite: Vector2 = global_position.direction_to(
		area.global_position
	)
	vector_opposite = - vector_opposite
	push_body(vector_opposite)

func _on_end_throw() -> void :
	chasing = true
	Enemy.change_state("fly")
	randomize()
	$TimerRandomSting.start(rand_range(2, 4))

func _on_TimerRandomSting_timeout() -> void :
	randomize()
	$TimerRandomSting.start(rand_range(2, 4))
	Enemy.change_direction("to_player")
	Enemy.change_state("throw")
	velocity = Vector2.ZERO


func _on_DetectPlayerNear_object_entered(Obj) -> void :
	if Enemy.state != "fly" or Enemy.state == "dead":
		return
	var vector_opposite: Vector2 = global_position.direction_to(
		Obj.global_position
	)
	vector_opposite = - vector_opposite
	push_body(vector_opposite)


func _on_VisibilityNotifierCameraArea_screen_exited() -> void :
	if Enemy.state == "dead":
		queue_free()
