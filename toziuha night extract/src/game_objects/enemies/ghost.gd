extends KinematicBody2D




var speed: int = 70
var velocity: Vector2

var _active: bool = false

var _is_player_on_area: bool

var _is_chasing: bool

onready var Enemy = $EnemyBase
onready var VisibNotif = $VisibilityNotifierCameraArea
onready var TimerAppearCooldown = $TimerAppearCooldown
onready var TimerPush = $TimerPush

func _physics_process(_delta: float) -> void :
	
	if Enemy.state in ["dead", "shriek"]:
		return
	
	if _is_chasing == true and TimerPush.is_stopped():
		Enemy.change_direction("to_player")
		velocity = Vector2.ZERO
		velocity = global_position.direction_to(
			Enemy.get_player_position() - Vector2(0, 30)
		) * speed
		
	elif TimerPush.is_stopped() == true:
		velocity = velocity / 2

	velocity = move_and_slide(velocity)

func start_random_shriek_timer() -> void :
	if $TimerStartShriek.is_stopped() == false:
		return
	$TimerStartShriek.start(2)


func push_body(direction: Vector2) -> void :
	
	if TimerAppearCooldown.is_stopped() == false:
		return
	
	randomize()
	
	
	var push_speed = 100
	var push_duration = 0.5

	
	var push_velocity = direction.normalized() * push_speed

	push_velocity.y += rand_range( - 30, 30)

	velocity = push_velocity

	
	TimerPush.start(push_duration)
	yield(TimerPush, "timeout")

	
	velocity = Vector2.ZERO

func _on_AppearAnimation_ended() -> void :
	
	TimerAppearCooldown.start()
	_is_chasing = true
	Enemy.change_state("idle")
	start_random_shriek_timer()

func _on_Area2D_area_entered(_area: Area2D) -> void :
	
	if Enemy.state in ["dead", "shriek"]:
		return
	
	_is_player_on_area = true
	
	if Enemy.state == "appear":
		return
	
	if _active == false:
		_active = true
		Enemy.change_state(
			"appear"
		)
	
	else:
		_is_chasing = true
		Enemy.change_state("idle")
		start_random_shriek_timer()


func _on_Area2D_area_exited(_area: Area2D) -> void :
	if Enemy.state in ["dead", "shriek"]:
		return
	_is_player_on_area = false
	
	


func _on_HurtboxEnemy_defeated() -> void :
	$Circles.visible = false
	Audio.stop_sfx("ghost_shriek")
	_is_chasing = false
	velocity = Vector2.ZERO


func _on_TimerStartShriek_timeout() -> void :
	randomize()
	if (
		Enemy.state != "dead"
		and Enemy.state != "appear"
		and VisibNotif.is_on_screen() == true
	):
		velocity = Vector2.ZERO
		if (
			_is_player_on_area == true
			and randi() % 2 == 1
		):
			Enemy.change_state("shriek")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name == "shriek":
		Enemy.change_state("idle")
		_on_Area2D_area_entered(Area2D.new())


func _on_HurtboxEnemy_area_entered(area: Area2D) -> void :
	if Enemy.state != "idle":
		return
	var vector_opposite: Vector2 = global_position.direction_to(
		area.global_position
	)
	vector_opposite = - vector_opposite
	
	push_body(vector_opposite)


func _on_DetectAnotherEnemiesHitbox_object_entered(_Obj) -> void :
	if Enemy.state != "idle":
		return
	var vector_opposite: Vector2 = global_position.direction_to(
		Enemy.get_player_position()
	)
	vector_opposite = - vector_opposite
	
	push_body(vector_opposite)


func _on_EnemyBase_state_changed(state: String) -> void :
	if state == "idle":
		$GhostTrail.start_trail()
	elif state == "dead":
		$GhostTrail.stop_trail()
