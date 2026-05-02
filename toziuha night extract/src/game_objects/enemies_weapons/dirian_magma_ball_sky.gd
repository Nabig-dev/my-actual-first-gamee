extends KinematicBody2D

var velocity: Vector2
var speed: float = 100
var dir: int = 1

func _ready() -> void :
	$GhostTrail.start_trail(0, 0.1)
	
	if dir == - 1:
		$AnimationPlayer.play("show")
	else:
		$AnimationPlayer.play_backwards("show")

func _physics_process(_delta: float) -> void :
	velocity.x = speed * dir
	velocity.y = speed
	velocity = move_and_slide(velocity)
	

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
