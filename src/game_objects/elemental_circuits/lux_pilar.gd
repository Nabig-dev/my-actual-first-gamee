extends Node2D

func _ready() -> void :
	Audio.play_sfx("light_flash4")
	Audio.play_sfx("light_flash3")
	Audio.play_sfx("shine3")
	Audio.play_sfx("shine")
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("float")


func _on_TimerLux_timeout() -> void :
	Audio.play_sfx("light_flash4")
	Audio.play_sfx("shine3")
	$Lux / AnimLux.play("show")


func _on_TimerEnd_timeout() -> void :
	Audio.play_sfx("light_flash2")
	$AnimationPlayer.play_backwards("show")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
