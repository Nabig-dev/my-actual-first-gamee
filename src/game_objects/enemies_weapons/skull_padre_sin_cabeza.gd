extends KinematicBody2D

var angle_variation: float

var target_position: Vector2
var speed: float = 400

var velocity: Vector2

func _ready() -> void :
	$AnimationPlayer.play("idle")
	velocity.y = - 80
	$ElPadreSinCabeza / CPUParticles2DSkulls.emitting = true

func _physics_process(delta: float):
	
	move_and_collide(velocity * delta)

func adjust_angle():
	
	var original_angle = velocity.angle()
	
	var adjusted_angle = original_angle + deg2rad(angle_variation)
	
	velocity = Vector2(cos(adjusted_angle), sin(adjusted_angle)) * speed
	
	$AnimatedSprite.rotation_degrees = 0
	$AnimatedSprite.set_rotation(velocity.angle())

func _on_Timer_timeout() -> void :
	
	$AnimationPlayer.play("fly")
	
	velocity = Vector2.ZERO
	
	speed = lerp(0, 350, 0.9)
	
	target_position = VarsGlobal.Player.global_position
	target_position.y -= 15
	velocity = position.direction_to(target_position).normalized() * speed
	adjust_angle()
	
	
	if VarsGlobal.Player.global_position < global_position:
		$ElPadreSinCabeza.scale.x = - 1

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
