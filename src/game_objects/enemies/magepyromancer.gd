extends KinematicBody2D

var Fireball = preload("res://src/game_objects/enemies_weapons/firebat_fireball.tscn")
var SkeletonFlame = preload("res://src/game_objects/enemies/flame_skeleton.tscn")

var speed: int = 50

var gravity: int = 0

var velocity: = Vector2.ZERO

var chasing: bool = false

onready var Enemy = $EnemyBase
onready var VisibilityNode = $VisibilityNotifierCameraArea
onready var GhostTrail = $GhostTrail
onready var TimerPush = $TimerPush

var chase_offset_y: float = - 40

func _ready() -> void :
	Enemy.change_state("fly")
	GhostTrail.start_trail()

func _physics_process(delta) -> void :
	if (
		Enemy.state == "fly"
		and chasing == true
		and VisibilityNode.is_on_screen()
		and TimerPush.is_stopped()
	):
		Enemy.change_direction("to_player")
		velocity = Vector2.ZERO
		velocity = global_position.direction_to(
			Enemy.get_player_position(Vector2(0, - 100 + chase_offset_y))
		) * speed
	elif Enemy.state != "dead" and TimerPush.is_stopped():
		velocity = Vector2.ZERO
	
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity)

func _on_VisibilityNotifierCameraArea_screen_entered() -> void :
	chasing = true
	randomize()
	$TimerRandomSting.start(rand_range(2, 4))

func _on_HurtboxEnemy_defeated() -> void :
	chasing = false
	gravity = 300
	GhostTrail.start_trail(0, 0.1)
	$Sprite.z_index = 0
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
	var StingInstance
	
	if get_tree().get_nodes_in_group("skeleton_flame").size() < 2:
		StingInstance = SkeletonFlame.instance()
		StingInstance.add_to_group("skeleton_flame")
	else:
		StingInstance = Fireball.instance()
	
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

func _on_TimerChangeOffset_timeout() -> void :
	if chase_offset_y == 0:
		chase_offset_y = - 40
	else:
		chase_offset_y = 0
