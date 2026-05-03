extends Node2D

var initial_speed: float = 250

onready var FireBall = $FireBall

func _ready() -> void :
	$FireCPUParticles2D.emitting = true

func _process(delta: float) -> void :
	FireBall.position.y -= initial_speed * delta
	initial_speed += 15


func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
