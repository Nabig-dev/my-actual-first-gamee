extends Node2D

export var delay_start: float = 0.0
export var delay_loop: bool = false

func _ready() -> void :
	if delay_start == 0.0:
		_on_TimerStart_timeout()
	else:
		$TimerStart.start(delay_start)

func _on_TimerStart_timeout() -> void :
	if delay_loop == true:
		$AnimationPlayer.play("show_no_loop")
	else:
		$AnimationPlayer.play("show")

func _on_TimerLoop_timeout() -> void :
	$AnimationPlayer.play("show_no_loop")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name == "show_no_loop":
		$TimerLoop.start(delay_loop)
