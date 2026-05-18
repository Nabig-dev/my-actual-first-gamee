extends Node2D

var dir: int
var _finish: bool
var tween_duration: float = 5
var tween_move: float = 400

func _ready() -> void :
	Audio.play_sfx("whoosh_fire")
	$AnimationPlayer.play("show")

	var Tw: = get_tree().create_tween()
	
	Tw.tween_property(
		self, "global_position:x", 
		global_position.x - (tween_move * dir), tween_duration
	
	).set_trans(Tween.TRANS_CUBIC)
	
	yield(Tw, "finished")
	
	_on_TimerActive_timeout()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name != "show":
		return
		
	if _finish == true:
		queue_free()

func _on_TimerActive_timeout() -> void :
	_finish = true
	$AnimationPlayer.play_backwards("show")
