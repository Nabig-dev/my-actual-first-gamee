extends Node2D

export var time_to_start: float = 1

func _ready() -> void :
	$Timer.start(time_to_start)

func _play_snd() -> void :
	if $VisibilityNotifier2D.is_on_screen() == true:
		Audio.play_sfx("toxic_release")

func _on_Timer_timeout() -> void :
	$AnimationPlayer.play("cascade")
