extends KinematicBody2D



var speed: int = 20
var velocity: Vector2

var total_swords = 4

var swords: Array

var _is_chasing: bool = false

onready var Enemy = $EnemyBase
onready var Spr = $Sprite
onready var TimerPush = $TimerPush
onready var Tw = $Tween
onready var TimerSendSword = $TimerSendSword
onready var VisibilityNotifierCameraArea = $VisibilityNotifierCameraArea

func _ready() -> void :
	Enemy.change_state("fly")
	swords = $Swords.get_children()
	
	yield(get_tree().create_timer(1), "timeout")
	_is_chasing = true

func send_sword() -> void :
	if Enemy.state == "fly" and VisibilityNotifierCameraArea.is_on_screen():
		randomize()
		swords.shuffle()
		for s in swords:
			if s.is_active == false and s.Enemy.state != "dead":
				s.start_chase()
				break

func _physics_process(delta: float) -> void :
	
	if Enemy.state in ["dead"] or VisibilityNotifierCameraArea.is_on_screen() == false:
		return
	
	if (
		_is_chasing == true and TimerPush.is_stopped()
		and global_position.distance_to(
			Enemy.get_player_position(Vector2(0, - 100))
		) > 10
		and VisibilityNotifierCameraArea.is_on_screen()
	):
		Enemy.change_direction("to_player")
		if Enemy.state == "fury":
			velocity = global_position.direction_to(
				Enemy.get_player_position(Vector2(0, - 60))
			) * (speed * 4)
		else:
			velocity = global_position.direction_to(
				Enemy.get_player_position(Vector2(0, - 100))
			) * speed
		
	elif TimerPush.is_stopped() == true:
		velocity = velocity / 2

	if Enemy.state == "dead":
		velocity.y += 200 * delta

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


func _shriek_snd() -> void :
	Audio.play_sfx("sword_master_shriek")

func _on_FloatingSword_defeated() -> void :
	total_swords -= 1
	if total_swords == 0:
		Audio.play_sfx("sword_slash_slow3")
		Enemy.change_state("awake")


func _on_Tween_tween_all_completed(degrees: int = 0) -> void :
	if Enemy.state != "dead":
		Enemy.change_direction("to_player")
	Tw.interpolate_property(
		Spr, "rotation_degrees", degrees, 360 * Enemy.facing, 2
	)
	Tw.start()


func _on_HurtboxEnemy_area_entered(area: Area2D) -> void :
	if Enemy.state == "dead":
		return
	var vector_opposite: Vector2 = global_position.direction_to(
		area.global_position
	)
	vector_opposite = - vector_opposite
	
	push_body(vector_opposite)


func _on_TimerSendSword_timeout() -> void :
	randomize()
	send_sword()
	TimerSendSword.start(rand_range(2, 5))
