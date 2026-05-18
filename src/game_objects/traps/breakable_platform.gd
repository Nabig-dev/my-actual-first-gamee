extends StaticBody2D

var player_entered: bool

func sfx_destroyed() -> void :
	Audio.play_sfx("rumble_long")
	Audio.play_sfx("rumble_long2")

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	player_entered = true
	$TimerBreak.start()
func _on_AreaDetectPlayer_area_exited(_area: Area2D) -> void :
	player_entered = false
	$TimerBreak.stop()

func _on_TimerBreak_timeout() -> void :
	
	if $BreakablePlatform.frame == 3:
		$AnimationPlayer.play("destroyed")
	elif VarsGlobal.Player.is_on_floor() == true:
		$BreakablePlatform.frame += 1
		Audio.play_sfx("rumble_short")
		Audio.play_sfx("rumble_short2")

