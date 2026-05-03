extends Node2D

func _ready() -> void :
	VarsGlobal.GameScenario.show_hit_lines(
		"hit_mid", 1, global_position
	)
	Audio.play_sfx("explosion_clean")
	VarsGlobal.GameScenario.CameraNode.start_shake(
		1.0, false, true
	)
