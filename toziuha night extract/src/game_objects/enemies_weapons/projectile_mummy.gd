extends KinematicBody2D

var dir: int = 1
var velocity: Vector2
var speed: float = 130

func _ready() -> void :
	$AnimationPlayer.play("fly")
	$Mummy.scale.x = dir

func _physics_process(_delta: float) -> void :
	velocity.x = speed * dir
	velocity = move_and_slide(velocity)


func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()


func _on_HurtboxEnemySimple_defeated() -> void :
	speed = 0
	velocity = Vector2.ZERO
	$AnimationPlayer.play("destroyed")
