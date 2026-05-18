extends KinematicBody2D

var auto_target: bool = true

var angle_variation: float

var target_position: Vector2

export var speed: float = 250.0

var update_velocity_process: bool

var velocity: Vector2

func _ready() -> void :
	$GhostTrail.start_trail(0, 0.1)
	if auto_target == true:
		target_position = VarsGlobal.Player.global_position
		target_position.y -= 25
	_update_velocity()
	adjust_angle()

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
	
	$Sprite.set_rotation(velocity.angle())

func _on_HurtboxEnemy_defeated() -> void :
	queue_free()

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()

func _on_HurtboxEnemySimple_defeated() -> void :
	queue_free()
