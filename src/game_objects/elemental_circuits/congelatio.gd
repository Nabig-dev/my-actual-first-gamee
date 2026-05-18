extends Node2D

func _ready():
	$Lux / AnimLux.play("show")
	Audio.play_sfx("ec_ice_start")
	Audio.play_sfx("ec_ice_end")

