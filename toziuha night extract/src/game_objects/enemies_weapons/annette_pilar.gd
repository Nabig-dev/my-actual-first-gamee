extends Node2D

export var delay_start: float = 0.0

func _ready() -> void :
	if delay_start <= 0.0:
		_on_TimerStart_timeout()
	$TimerStart.start(delay_start)

func _snd() -> void :
	Audio.play_sfx("atk_charge_completed")
	Audio.play_sfx("ec_ice_start")

func _on_TimerStart_timeout() -> void :
	$AnimationPlayer.play("show")
