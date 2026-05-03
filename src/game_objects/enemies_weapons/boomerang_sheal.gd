extends KinematicBody2D

var dir: int = 1
var velocity: Vector2
var speed: float = 300

var _returning: bool

func _ready() -> void :
	$Sprite.scale.x = dir
	$AnimationPlayer.play("fly")
	$GhostTrail.start_trail(0, 0.01)

func _physics_process(delta: float) -> void :
	velocity.x = speed * dir
	velocity = move_and_slide(velocity)
	
	global_position.y += 10 * delta


func _on_Timer_timeout() -> void :
	$Wosh.play()


func _on_VisibilityNotifier2D_screen_exited() -> void :
	
	if _returning == true:
		queue_free()
	else:
		_returning = true
		dir = dir * - 1
		$Sprite.scale.x = dir
