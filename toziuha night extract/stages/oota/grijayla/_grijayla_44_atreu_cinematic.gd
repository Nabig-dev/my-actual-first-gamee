extends Node2D

func play_snd(snd: String) -> void :
	Audio.play_sfx(snd)

func stop_snd(snd: String) -> void :
	Audio.stop_sfx(snd)
