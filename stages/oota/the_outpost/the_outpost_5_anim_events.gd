extends Node

var ParticlesBlood = preload("res://src/game_objects/vfx/particles_blood_smash.tscn")

func laugh() -> void :
	Audio.play_sfx("laugh_low_tone_1")

func smash_sfx() -> void :
	Audio.play_sfx("impact_smash")
	Audio.play_sfx("impact_earth")
	VarsGlobal.GameScenario.CameraNode.start_shake(
		0.3, false, true
	)
	Gamepad.start_vibration(0, 0.4, 0.1, 0.3)
	var ObjInstance = ParticlesBlood.instance()
	VarsGlobal.GameScenario.get_node("Cutscene/Position2DBloodImpact").call_deferred("add_child", ObjInstance)
	

func _player_jump() -> void :
	
	VarsGlobal.Player.jump()

func _player_stop_move() -> void :
	VarsGlobal.Player.stop_move()

func _player_backdash_inverse() -> void :
	VarsGlobal.Player.move(Vector2.RIGHT)
	VarsGlobal.Player.stop_move()
	VarsGlobal.Player.backdash()
	
