extends Node2D

func _ready() -> void :
	$AnimationPlayer.play("show")
	Audio.play_sfx("explosion_clean")
	Audio.play_sfx("explosion_grijayla_cinematic")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.6, false, true)
	Gamepad.start_vibration(0, 0.6, 0.5, 0.6)
