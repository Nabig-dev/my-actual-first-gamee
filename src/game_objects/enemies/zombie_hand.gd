extends RigidBody2D

onready var Enemy = $EnemyBase

func _ready() -> void :
	Enemy.change_state("inactive")


func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	if Enemy.state == "inactive":
		Audio.play_sfx("floor_slide2")
		Audio.play_sfx("enemy_zombie_roar2")
		Enemy.change_state("wakeup")
