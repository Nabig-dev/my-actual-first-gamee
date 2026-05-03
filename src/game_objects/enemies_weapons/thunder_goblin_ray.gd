extends Node2D

func _ready() -> void :
	$AnimationPlayer.play("start")

func _snd_prethunder() -> void :
	Audio.play_sfx("pre_thunder")
func _snd_thunder() -> void :
	Audio.play_sfx("thunder_3")
