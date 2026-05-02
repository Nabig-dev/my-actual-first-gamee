extends KinematicBody2D

var angle_variation: float

var target_position: Vector2

export var speed: float = 250.0

var update_velocity_process: bool

var velocity: Vector2

var auto_target: bool = true

func _ready() -> void :
	randomize()
	Audio.play_sfx("spell_shoot")
	Audio.play_sfx("woosh_ignite_fire")
	if auto_target == true:
		target_position = global_position - Vector2(rand_range( - 15, 15), 50)
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
	
	$Node2D.set_rotation(velocity.angle())

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
