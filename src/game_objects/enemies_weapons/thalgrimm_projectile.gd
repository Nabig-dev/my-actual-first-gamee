extends KinematicBody2D

var color: = Color("47ff9e21")

var dir: int = 1
var target_position: Vector2
var speed: float = 400.0

var velocity: Vector2

func _ready() -> void :
	$GhostTrail.modulate_ghost = color
	$GhostTrail.start_trail()
	$AnimationPlayer.play("idle")
	$Projectile.scale.x = dir
	
	target_position = VarsGlobal.Player.global_position
	target_position.y -= 20
	velocity = position.direction_to(target_position).normalized() * speed

func _physics_process(delta: float):
	
	move_and_collide(velocity * delta)

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()

func _on_HurtboxEnemySimple_defeated() -> void :
	set_physics_process(false)
	$AnimationPlayer.play("destroy")
