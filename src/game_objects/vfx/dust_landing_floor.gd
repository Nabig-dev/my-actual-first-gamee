extends Node2D

var anim_name = "show_1"

func _ready() -> void :
	$AnimationPlayer.play(anim_name)
