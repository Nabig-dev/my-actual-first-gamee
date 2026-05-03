extends Node2D

var anim_name = "show2"

func _ready() -> void :
	$AnimationPlayer.play(anim_name)
