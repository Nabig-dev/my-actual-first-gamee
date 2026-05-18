extends Node2D

var time_active: float = 3

func _ready() -> void :
	Audio.play_sfx("spell_prepare2")
	$AnimationPlayer.play("show")

func _start_fire_snd() -> void :
	Audio.play_sfx("fire_burning_loop", true, 0.3)
func _stop_fire_snd() -> void :
	Audio.stop_sfx("fire_burning_loop", true)

func _on_Timer_timeout() -> void :
	_stop_fire_snd()
	$AnimationPlayer.play("hide")

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name == "show":
		$Timer.start(time_active)
	elif anim_name == "hide":
		queue_free()

func _on_DirianPilarFireDouble_tree_exiting() -> void :
	_stop_fire_snd()
