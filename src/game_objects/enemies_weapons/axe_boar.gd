extends KinematicBody2D

var dir: int

var _vel_y: float = 0

var _returning: bool = false
var _defeated: bool = false

var velocity: Vector2
var speed: float = 230

var Tw: SceneTreeTween

func _ready() -> void :
	$GhostTrail.start_trail(0, 0.1)
	$Sprite.scale.x = dir
	
	if dir == 1:
		$AnimationPlayer.play("idle")
	elif dir == - 1:
		$AnimationPlayer.play_backwards("idle")
		
	$Timer.start(1)
	yield($Timer, "timeout")
	
	Tw = create_tween()
	
	
	Tw.tween_property(
		self, "speed", speed * - 1, 1
	)
	
	
	Tw.parallel().tween_property(
		self, "_vel_y", 64, 1
	)
	
	yield(Tw, "finished")
	_vel_y = 0
	_returning = true


func _physics_process(_delta: float) -> void :
	velocity.x = speed * dir
	velocity.y = _vel_y
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_VisibilityNotifier2D_screen_exited() -> void :
	if _returning == true or _defeated == true:
		queue_free()


func _on_HurtboxEnemySimple_defeated() -> void :
	$GhostTrail.stop_trail()
	$Timer.stop()

	_defeated = true
	
	if dir == 1:
		$AnimationPlayer.play("destroyed")
	elif dir == - 1:
		$AnimationPlayer.play_backwards("destroyed")
	
	set_physics_process(false)










