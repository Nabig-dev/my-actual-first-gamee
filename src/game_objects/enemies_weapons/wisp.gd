extends Node2D

func _ready() -> void :
	Audio.play_sfx("spell_prepare3")
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")
	Audio.play_sfx("floating_sword_prepared")
	Audio.play_sfx("thunder_2")
	randomize()
	if randi() % 2 == 0:
		$AnimationPlayer.play("spin")
	else:
		$AnimationPlayer.play_backwards("spin")
	yield($AnimationPlayer, "animation_finished")
	$TimerZap.stop()
	$AnimationPlayer.playback_speed = 4
	$AnimationPlayer.play_backwards("show")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func _on_TimerZap_timeout() -> void :
	Audio.play_sfx("pre_thunder")
