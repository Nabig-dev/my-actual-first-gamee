extends Node2D

func start() -> void :
	$AnimationPlayer.play("show")
func stop() -> void :
	$AnimationPlayer.play("RESET")
