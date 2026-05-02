extends KinematicBody2D

var speed: int = 30
var velocity: Vector2
var chasing: bool

onready var TimerPush = $TimerPush
onready var Tw = $Tween
onready var Enemy = $EnemyBase
onready var VisibNotif = $VisibilityNotifier2D


func _physics_process(_delta: float) -> void :
	if (
		VisibNotif.is_on_screen() == true
		and Enemy.state == "fly"
		and TimerPush.is_stopped() == true
	):
		
		velocity = Vector2.ZERO
		
		velocity = global_position.direction_to(
			Enemy.get_player_position(Vector2(0, - 30))
		) * speed
	
	velocity = move_and_slide(velocity)

func push_body(direction: Vector2) -> void :
	chasing = false
	randomize()
	
	
	var push_speed = 100
	var push_duration = 0.5

	
	var push_velocity = direction.normalized() * push_speed

	push_velocity.y += rand_range( - 30, 30)

	velocity = push_velocity

	
	TimerPush.start(push_duration)
	yield(TimerPush, "timeout")

	
	velocity = Vector2.ZERO
	
	chasing = true

func _on_HurtboxEnemy_area_entered(area: Area2D) -> void :
	Tw.remove_all()
	Tw.stop_all()
	
	if Enemy.state != "fly":
		return
	
	var vector_opposite: Vector2 = global_position.direction_to(
		area.global_position
	)
	vector_opposite = - vector_opposite
	
	push_body(vector_opposite)

func _on_show_anim_ended() -> void :
	chasing = true
	Enemy.change_state("fly")


func _on_Timer_timeout() -> void :
	Enemy.change_state("show")
