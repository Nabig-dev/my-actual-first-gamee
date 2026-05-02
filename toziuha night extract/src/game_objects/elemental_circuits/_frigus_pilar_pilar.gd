extends Node2D

func _ready() -> void :
	$AnimationPlayer.play("show")

func sfx_start() -> void :
	Audio.play_sfx("ec_ice_start")
func sfx_end() -> void :
	Audio.play_sfx("ec_ice_end")
