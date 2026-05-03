extends RigidBody2D

var Shoot = preload("res://src/game_objects/enemies_weapons/evilvine_shoot.tscn")

onready var Enemy = $EnemyBase
onready var VisibNotif = $VisibilityNotifierCameraArea

func shoot() -> void :
	var ObjInstance = Shoot.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = $Sprite / PositionShoot.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _on_after_shoot() -> void :
	Enemy.change_direction("to_player")
	Enemy.change_state("idle")

func _on_TimerShoot_timeout() -> void :
	if VisibNotif.is_on_screen() == false:
		$TimerShoot.start(1)
		return

	Enemy.change_direction("to_player")
	Enemy.change_state("shoot")
	randomize()
	$TimerShoot.start(rand_range(1.5, 2.5))
