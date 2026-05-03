extends Node2D

func _ready() -> void :
	Audio.play_sfx("woosh_ignite_fire")
	$AnimationPlayer.play("show")


func _on_TimerAutoHide_timeout() -> void :
	if $AnimationPlayer.current_animation == "loop":
		$AnimationPlayer.play("dead")


func _on_HurtboxEnemySimple_defeated() -> void :
	$AnimationPlayer.play("dead")
