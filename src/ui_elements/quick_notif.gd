extends Label

var to_queue: bool

func _ready() -> void :
	$AnimationPlayer.play("show")

func _on_Timer_timeout() -> void :
	$AnimationPlayer.play_backwards("show")

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void :
	if $AnimationPlayer.current_animation_position == 0:
		queue_free()
