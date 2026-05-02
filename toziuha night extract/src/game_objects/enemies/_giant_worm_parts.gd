extends Node2D

export var is_head: bool = true
export var play_backwards: bool = false

func _ready() -> void :
	var _anim: String = "head"
	if is_head == false:
		_anim = "body"
	
	if play_backwards == false:
		$AnimationPlayer.play(_anim)
	else:
		$AnimationPlayer.play_backwards(_anim)

func trail_on() -> void :
	$GhostTrail.start_trail()
func trail_off() -> void :
	$GhostTrail.stop_trail()
