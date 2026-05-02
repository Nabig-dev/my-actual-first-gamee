extends Path2D

export var dir: int = 1
export var time_active: float = 5
export var anim_speed: float = 0.3

var is_active: bool
	
func startmove() -> void :
	Audio.play_sfx("electric_zap3")
	$AnimMove.playback_speed = anim_speed
	if is_active == false:
		is_active = true
		$AnimSprite.play("show")
		$AnimMove.play("show")
		if dir == - 1:
			$PathFollow2D / Sprite.rotation_degrees = 90
		else:
			$PathFollow2D / Sprite.rotation_degrees = - 90

func stopmove() -> void :
	if is_active == true:
		$PathFollow2D.unit_offset = 0
		is_active = false

func _on_Timer_timeout() -> void :
	$AnimMove.play("hide")
	$AnimSprite.play("hide")

func _on_AnimSprite_animation_finished(anim_name: String) -> void :
	if anim_name == "show":
		if dir == - 1:
			$AnimMove.play("move")
		else:
			$AnimMove.play_backwards("move")
		$AnimSprite.play("move")
		$Timer.start(time_active)
	
	elif anim_name == "move":
		Audio.play_sfx("pre_thunder")
	
	elif anim_name == "hide":
		stopmove()
