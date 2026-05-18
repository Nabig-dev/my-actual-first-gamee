extends Control

onready var BarDamage = $BarDamage
onready var BarProgress = $BarProgress

onready var Tw = $Tween
onready var TimerDelayTween = $TimerDelayTween
onready var Anim = $AnimationPlayer

func start_bar(
	max_value: int = 100
) -> void :
	Anim.playback_speed = 1
	Anim.play("show")
	
	BarDamage.max_value = max_value
	BarDamage.value = max_value
	BarProgress.max_value = max_value
	BarProgress.value = max_value

func hide_bar() -> void :
	Anim.playback_speed = 2
	Anim.play_backwards("show")

func set_value(val: int) -> void :
	BarProgress.value = val
	TimerDelayTween.start()

func _on_TimerDelayTween_timeout() -> void :
	Tw.stop_all()
	Tw.interpolate_property(
		BarDamage, "value", 
		BarDamage.value, BarProgress.value, 
		3, 
		Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	Tw.start()
