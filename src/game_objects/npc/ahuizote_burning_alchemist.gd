extends Node2D

func _ready() -> void :
	play_anim()

func play_anim(animation_player: String = "idle") -> void :
	$AnimationPlayer.play(animation_player)
