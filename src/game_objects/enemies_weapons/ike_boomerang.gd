extends KinematicBody2D

var dir: int = 1
var velocity: Vector2
var speed: float = 400

var _returning: bool

func _ready() -> void :
	Audio.play_sfx("shoot_projectile_light")
	Audio.play_sfx("sword_slash_slow4")
	$Sprite.scale.x = dir
	if dir == 1:
		$AnimationPlayer.play("fly")
	else:
		$AnimationPlayer.play_backwards("fly")
	$GhostTrail.start_trail(0, 0.1)

func _physics_process(delta: float) -> void :
	velocity.x = speed * dir
	velocity = move_and_slide(velocity)
	
	global_position.y -= 20 * delta

func _on_Timer_timeout() -> void :
	$Wosh.play()

func _on_VisibilityNotifier2D_screen_exited() -> void :
	if $TimerCoolDown.is_stopped() == false:
		return
	$TimerCoolDown.start(0.2)
	if _returning == true:
		queue_free()
	else:
		_returning = true
		dir = dir * - 1
		$Sprite.scale.x = dir

func _on_TimerQueue_timeout() -> void :
	if $VisibilityNotifier2D.is_on_screen() == false:
		queue_free()
