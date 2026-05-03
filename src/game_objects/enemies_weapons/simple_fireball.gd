extends KinematicBody2D


var angle_degrees: float = 0.0

var speed: float = 200.0
var dir: int = 1

var velocity: Vector2

func _ready() -> void :
	$AnimationPlayer.play("idle")
	$Sprite.rotation_degrees = angle_degrees * - dir
	$Sprite.scale.x = dir
	
	velocity = Vector2(
		cos(deg2rad(angle_degrees)) * dir, - sin(deg2rad(angle_degrees))
	) * speed

func _physics_process(delta: float):
	
	move_and_collide(velocity * delta)
	


func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()


func _on_HurtboxEnemySimple_defeated() -> void :
	queue_free()
