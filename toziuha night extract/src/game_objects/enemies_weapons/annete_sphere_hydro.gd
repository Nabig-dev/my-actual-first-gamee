extends KinematicBody2D

var angle_variation: float

var target_position: Vector2

export var speed: float = 0

var update_velocity_process: bool

var velocity: Vector2

func _ready() -> void :
	
	
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("loop")

func start_move(spe: float = 250, trail: bool = false) -> void :
	speed = spe
	_update_velocity()
	adjust_angle()
	$TimerIncreaseSpeed.start()
	if trail == true:
		$GhostTrail.start_trail(0, 0.1)

func _physics_process(delta: float):
	
	if update_velocity_process == true:
		_update_velocity()
	
	
	move_and_collide(velocity * delta)

func _update_velocity() -> void :
	velocity = position.direction_to(target_position).normalized() * speed

func adjust_angle():
	
	var original_angle = velocity.angle()
	
	var adjusted_angle = original_angle + deg2rad(angle_variation)
	
	velocity = Vector2(cos(adjusted_angle), sin(adjusted_angle)) * speed


func _on_TimerEnd_timeout() -> void :
	queue_free()


func _on_TimerIncreaseSpeed_timeout() -> void :
	speed += 30
