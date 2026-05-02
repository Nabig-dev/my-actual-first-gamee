extends Node2D

signal stoped

func _ready() -> void :
	visible = false

func _on_TimerCheckSolid_timeout() -> void :
	if $DetectSolid.is_colliding() == true:
		visible = true
		Audio.play_sfx("explosion_light2")
		$AnimationPlayer.play("show")
		VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
		Gamepad.start_vibration(0, 0.4, 0.4, 0.5)
	else:
		emit_signal("stoped")
		queue_free()
