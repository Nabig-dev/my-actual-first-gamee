extends RigidBody2D

var dir: int = 1

func _ready() -> void :
	Audio.play_sfx("ec_ice_start")
	Audio.play_sfx("impact_mineral")
	$IceFloor.scale.x = dir
	$AnimationPlayer.play("show")
