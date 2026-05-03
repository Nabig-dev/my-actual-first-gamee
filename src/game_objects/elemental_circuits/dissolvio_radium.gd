extends Node2D

func _ready() -> void :
	$AnimationPlayer.play("show")
	Audio.play_sfx("laserbeam")
	Audio.play_sfx("lasershort2")
