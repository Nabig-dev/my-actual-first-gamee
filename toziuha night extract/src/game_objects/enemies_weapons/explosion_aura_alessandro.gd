extends Node2D

func play() -> void :
	$AnimationPlayer.play("show")
func stop() -> void :
	$AnimationPlayer.play("RESET")
