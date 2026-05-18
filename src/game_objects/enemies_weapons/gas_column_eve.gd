extends Node2D

var time_active: float = 5

func _ready() -> void :
	$Timer.start(time_active)

func _on_Timer_timeout() -> void :
	$AnimationPlayer.play("hide")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
