extends KinematicBody2D

var dir: int = 1
var moving: bool

func _ready() -> void :
	$PreGas.emitting = true
	$Gas.emitting = false

func _physics_process(delta: float) -> void :
	if moving:
		global_position.x += (50 * dir) * delta

func _on_Timer_timeout() -> void :
	moving = true
	
	$Gas.emitting = true
