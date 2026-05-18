extends KinematicBody2D

onready var Enemy = $EnemyBase

func _ready() -> void :
	Enemy.change_state("idle", true)

func _snd_laserstarted() -> void :
	Audio.play_sfx("laserbeam")

func _snd_laserstart() -> void :
	Audio.play_sfx("lasershort2")

func _on_laserend() -> void :
	Enemy.change_state("idle", true)
	if rotation_degrees == 0:
		Enemy.change_direction("to_player")
	if $Octolaser / AreaSeePlayer.is_colliding() == true:
		Enemy.change_state("laser", true)

func _on_AreaSeePlayer_object_entered(_Obj) -> void :
	if $TimerStartShoot.is_stopped() == true:
		$TimerStartShoot.start()

func _on_TimerStartShoot_timeout() -> void :
	if Enemy.state == "idle":
		Enemy.change_state("laser", true)

func _on_VisibilityNotifier2D_screen_entered() -> void :
	if Enemy.state == "idle" and rotation_degrees == 0:
		Enemy.change_direction("to_player")

func _on_HurtboxEnemy_defeated() -> void :
	Audio.stop_sfx("lasershort2")

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state == "idle" and rotation_degrees == 0:
		Enemy.change_direction("to_player")

func _on_TimerAutoFacing_timeout() -> void :
	if rotation_degrees == 0:
		Enemy.change_direction("to_player")

func _on_Area2DDetectPlayer_area_entered(_area: Area2D) -> void :
	_on_VisibilityNotifier2D_screen_entered()
