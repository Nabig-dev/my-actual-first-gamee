extends Node2D

func _ready() -> void :
	randomize()
	$Node2D.position.x = rand_range( - 20, 10)
	Audio.play_sfx("whip_wosh_large")
	Audio.play_sfx("crystal_soul_get2")
	$AnimationPlayer.play("show")
