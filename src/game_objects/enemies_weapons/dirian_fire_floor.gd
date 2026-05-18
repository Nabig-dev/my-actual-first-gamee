extends RigidBody2D

var time_active: float = 5

func _ready() -> void :
	Audio.play_sfx("woosh_ignite_fire")
	Audio.play_sfx("fireball_short")
	$Node2D / AnimationPlayer.play("show")
	yield($Node2D / AnimationPlayer, "animation_finished")
	$Node2D / Timer.start(time_active)

func _on_Timer_timeout() -> void :
	$Node2D / AnimationPlayer.play("hide")
