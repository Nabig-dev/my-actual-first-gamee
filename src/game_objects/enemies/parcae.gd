extends KinematicBody2D

var speed: int = 200
var velocity: Vector2
var chasing: bool = true

onready var TimerPush = $TimerPush
onready var Tw = $Tween
onready var Enemy = $EnemyBase
onready var VisibilityNotifierCameraArea = $VisibilityNotifierCameraArea

onready var Spr = $Sprite
onready var SprCopy = $Sprite / SpriteCopy

func _physics_process(_delta: float) -> void :
	if (
		VisibilityNotifierCameraArea.is_on_screen() == false
		and Enemy.state == "fly"
	):
		
		Enemy.change_direction("to_player")
		
		
		velocity = Vector2.ZERO
		
		velocity = global_position.direction_to(
			Enemy.get_player_position(Vector2(0, - 30))
		) * speed
	
	velocity = move_and_slide(velocity)

func start_chase() -> void :
	
	if Enemy.state in ["dead"]:
		return

	Tw.remove_all()
	Tw.stop_all()
	randomize()
	
	
	var chase_duration = 2
	
	
	
	Enemy.change_direction("to_player")
	chasing = true
	Tw.interpolate_property(
		self, 
		"global_position", 
		global_position, 
		Enemy.get_player_position(Vector2(0, - 32)), 
		chase_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	Tw.start()
	
	chasing = true

func random_move(distance: int = 60) -> void :

	if Enemy.state in ["dead"]:
		return
	
	Enemy.change_direction("to_player")
	
	var random_pos: Array = [
		Vector2( - distance, - distance), 
		Vector2(distance, - distance), 
		Vector2( - distance, distance), 
		Vector2(distance, distance)
	]

	chasing = false
	Tw.remove_all()
	Tw.stop_all()
	randomize()
	
	Tw.interpolate_property(
		self, 
		"global_position", 
		global_position, 
		global_position + random_pos[randi() % 4], 
		rand_range(1, 2), Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	
	Tw.start()
	
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
	
	random_move(20)

func _on_TimerChase_timeout() -> void :
	start_chase()

func _on_Tween_tween_completed(_object: Object, _key: NodePath) -> void :

	if VisibilityNotifierCameraArea.is_on_screen() == false:
		return
	
	if chasing == false:
		$TimerChase.start(0.5)
	else:
		random_move()

func _on_VisibilityNotifierCameraArea_screen_entered() -> void :
	if Enemy.state == "fly":
		randomize()
		if randi() % 2 == 0:
			random_move()
		else:
			start_chase()

func _on_VisibilityNotifierCameraArea_screen_exited() -> void :
	pass

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

func _on_Tween_tween_started(_object: Object, _key: NodePath) -> void :
	$GhostTrail.start_trail(0.0, 0.1)

func _on_Sprite_frame_changed() -> void :
	SprCopy.frame = Spr.frame

func _on_EnemyBase_enemy_defeated(_NodeEnemy) -> void :
	$GhostTrail.stop_trail()

func _on_TimerActive_timeout() -> void :
	Enemy.change_state("fly")
