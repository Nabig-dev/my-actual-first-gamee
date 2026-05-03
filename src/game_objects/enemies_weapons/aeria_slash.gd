extends KinematicBody2D

var velocity: Vector2
var dir: int = 1

func _ready() -> void :
	$GhostTrail.start_trail(0, 0.05)
	$AnimationPlayer.play("fly")
	$AeriaSlash.scale.x = dir

func _physics_process(_delta: float) -> void :
	velocity.x = 300 * dir
	velocity = move_and_slide(
		velocity, Vector2.UP
	)

func _on_HurtboxEnemySimple_defeated() -> void :
	$AnimationPlayer.play("destroy")
	velocity.x = 0
	set_physics_process(false)
