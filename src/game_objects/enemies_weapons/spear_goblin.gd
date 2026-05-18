extends KinematicBody2D

var dir: int

var velocity: Vector2
var speed: float = 15000

func _ready() -> void :
	$AnimationPlayer.play("idle")
	$GoblinSpear.scale.x = dir

func _physics_process(delta: float) -> void :
	velocity.x = (speed * dir) * delta
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_HurtboxEnemySimple_defeated() -> void :
	queue_free()

func _on_VisibilityNotifier2D_screen_exited() -> void :
	_on_HurtboxEnemySimple_defeated()
