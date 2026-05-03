extends Node2D

func _ready() -> void :
	Audio.play_sfx("ec_shoot2")
	Audio.play_sfx("elyndra_death")
	$AnimationPlayer.play("spawn")
