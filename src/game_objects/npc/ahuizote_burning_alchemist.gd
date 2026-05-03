extends Node2D

func _ready() -> void :
	play_anim()

func play_anim(anim: String = "idle") -> void :
	$AnimationPlayer.play(anim)
