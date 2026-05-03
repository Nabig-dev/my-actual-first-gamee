extends Node2D

func _ready() -> void :
	Audio.play_sfx("water_splash_in3")
	$AnimationPlayer.play("loop")
	$AnimationPlayer2.play("show")

func _on_TimerEnd_timeout() -> void :
	Audio.play_sfx("water_splash_out2")
	$AnimationPlayer2.play_backwards("show")
	yield($AnimationPlayer2, "animation_finished")
	queue_free()
