extends Node2D

func activate() -> void :
	Audio.play_sfx("atk_blood_completed")
	$ParticlesCharge.emitting = true
	Audio.play_sfx("crystal_soul_generated2")
	$AnimationPlayer.play("activate")
