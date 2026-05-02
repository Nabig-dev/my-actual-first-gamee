extends Node2D

var dir: int = 1

func _ready() -> void :
	
	Audio.play_sfx("roar_dragon")
	scale.x = dir
	$AnimationPlayer.play("show")
