extends KinematicBody2D

var speed: int = 50
var velocity: Vector2

var _active: bool = false

var _is_chasing: bool = true

onready var Enemy = $EnemyBase
onready var TimerPush = $TimerPush

func _ready() -> void :
	Enemy.change_state("fly", true)

func _physics_process(_delta: float) -> void :
	
	if Enemy.state in ["dead"]:
		return
	


	
	if _is_chasing == true and TimerPush.is_stopped():
		Enemy.change_direction("to_player")
		velocity = Vector2.ZERO
		velocity = global_position.direction_to(
			Enemy.get_player_position(Vector2(0, - 40))
		) * speed
		
	elif TimerPush.is_stopped() == true:
		velocity = velocity / 2

	velocity = move_and_slide(velocity)


func push_body(direction: Vector2) -> void :
	randomize()
	
	
	var push_speed = 100
	var push_duration = 0.5

	
	var push_velocity = direction.normalized() * push_speed

	push_velocity.y += rand_range( - 30, 30)

	velocity = push_velocity

	
	TimerPush.start(push_duration)
	yield(TimerPush, "timeout")

	
	velocity = Vector2.ZERO

func _on_attack_end() -> void :
	Enemy.change_state("fly")
	randomize()
	$TimerAtk.start(rand_range(3, 4))

func _on_HurtboxEnemy_area_entered(area: Area2D) -> void :
	if Enemy.state in ["fly", "attack"]:
		var vector_opposite: Vector2 = global_position.direction_to(
			area.global_position
		)
		vector_opposite = - vector_opposite
		
		push_body(vector_opposite)


func _on_TimerAtk_timeout() -> void :
	
	if $VisibilityEnabler2D.is_on_screen() == true and Enemy.state == "fly":
		Enemy.change_state("attack")
		Audio.play_sfx("floating_sword_prepared")
		Audio.play_sfx("terrific_death2")
	$TimerAtk.start(1)

func _on_VisibilityEnabler2D_screen_entered() -> void :
	randomize()
	$TimerAtk.start(rand_range(2, 3))
