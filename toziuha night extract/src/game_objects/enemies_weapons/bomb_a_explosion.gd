extends Node2D

func _ready() -> void :
	Audio.play_sfx("explosion_clean")
	VarsGlobal.GameScenario.CameraNode.start_shake(
		0.5, false, true
	)
	Gamepad.start_vibration(0, 0.3, 0.2, 0.3)
