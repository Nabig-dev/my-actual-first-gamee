extends Node2D

func _ready() -> void :
	Audio.play_sfx("ec_ice_start2")
	randomize()
	rotation_degrees = RNGTools.pick(
		[0, 90, 180, 90]
	)
	
	$AnimationPlayer.play("show")
