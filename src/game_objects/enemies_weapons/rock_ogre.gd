extends KinematicBody2D

var dir: int = 1

var gravity: float = 500
var velocity: = Vector2.ZERO
var target_position: = Vector2.ZERO

func _ready() -> void :
	
	
	
	var arc_height = target_position.y - global_position.y - 100
	
	arc_height = min(arc_height, - 32)
	
	velocity = PhysicsHelper.calculate_arc_vel(
		global_position, target_position, arc_height, gravity
	)
	velocity = velocity.limit_length(300)

func _physics_process(delta: float) -> void :
	
	velocity.y += gravity * delta
	
	
	var collision = move_and_collide(velocity * delta)

func _on_HurtboxEnemy_defeated() -> void :
	
	
	$RockFloor.visible = false
	$CPUParticles2D.emitting = true

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
