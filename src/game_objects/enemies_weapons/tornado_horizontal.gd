extends KinematicBody2D

var dir: int = 1

var speed: float = 0

var velocity: Vector2

func _ready() -> void :
	$Sprite.scale.x = dir
	$AnimationPlayer.play("show")

func _physics_process(_delta: float) -> void :
	
	velocity.x = speed * dir
	velocity.y += 0.5
	
	move_and_slide(velocity)

func _on_TimerEnd_timeout() -> void :
	if $AnimationPlayer.current_animation != "dissapear":
		$AnimationPlayer.play("dissapear")

func _on_AnimationPlayer_animation_started(anim_name: String) -> void :
	if anim_name == "loop":
		speed = lerp(0, 280, 0.8)

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
