extends Node2D

func newplatform_up() -> void :
	Audio.play_sfx("door_opening")
	VarsGlobal.GameScenario.CameraNode.start_shake(
		0.2, false, 
		true, false
	)
	Gamepad.start_vibration(0, 0.8, 0.8, 0.5)
