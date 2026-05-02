extends Node2D

var time_to_start: float = 0.5

func _ready() -> void :
	$Timer.start(time_to_start)
	yield($Timer, "timeout")
	global_position.x = VarsGlobal.Player.global_position.x
	$AnimationPlayer.play("start")

func _snd_prethunder() -> void :
	Audio.play_sfx("pre_thunder")
func _snd_thunder() -> void :
	Audio.play_sfx("thunder_3")
