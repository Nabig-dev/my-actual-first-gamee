extends Node2D

func _ready() -> void :
	$AnimationPlayer.play("show")

func rumble() -> void :
	Audio.play_sfx("explosion_light2")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.3, false, false)
	Gamepad.start_vibration(0, 0.3, 0.3, 0.3)
