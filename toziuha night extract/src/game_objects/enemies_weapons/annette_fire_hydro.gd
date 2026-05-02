extends RigidBody2D

var time_active: float = 5

func _ready() -> void :
	Audio.play_sfx("woosh_ignite_fire")
	$Node2D / Timer.start(time_active)
	$Node2D / AnimationPlayer.play("show")

func snd_fire() -> void :
	Audio.play_sfx("floating_sword_prepared")

func _on_Timer_timeout() -> void :
	$Node2D / AnimationPlayer.play("hide")
