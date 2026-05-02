extends Node

func witikojump() -> void :
	VarsGlobal.GameInterface.show_flash()
	Audio.play_sfx("monster_impact")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.9)
	Gamepad.start_vibration(0, 0.9, 0.9, 0.8)
	

func lightflash() -> void :
	Audio.play_sfx("light_flash")
