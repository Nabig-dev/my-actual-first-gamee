extends KinematicBody2D

var dir: int = 1
var dir_y: int = - 1
var speed: float = 300
var velocity: Vector2

func _ready() -> void :
	Audio.play_sfx("shoot_projectile")
	$GhostTrail.start_trail(0, 0.1)
	$Sprite.scale.x = dir

func _physics_process(delta: float) -> void :
	velocity.x = speed * dir
	velocity = move_and_slide(velocity)
	
	global_position.y += (dir_y * 30) * delta

func _on_HurtboxEnemySimple_defeated() -> void :
	$GhostTrail.stop_trail()
	set_physics_process(false)
	$AnimationPlayer.play("destroyed")


func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
