extends Node2D

var AcidShoot = preload("res://src/game_objects/enemies_weapons/acid_shoot.tscn")

onready var Target = $Node2D / Position2D

var dir: int = 1

func _ready() -> void :

	Audio.play_sfx("spell_prepare")
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")
	if dir == - 1:
		$AnimationPlayer.play("spin")
	else:
		$AnimationPlayer.play_backwards("spin")
	_on_TimerSpawn_timeout()
	$TimerSpawn.start(0.25)
	yield($AnimationPlayer, "animation_finished")
	$TimerSpawn.stop()
	$AnimationPlayer.play_backwards("show")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
	
func _spawn_acidrain() -> void :
	var ObjInstance = AcidShoot.instance()
	ObjInstance.global_position = global_position
	ObjInstance.target_position = Target.global_position
	ObjInstance.speed = 400
	ObjInstance.collide = false
	ObjInstance.auto_target = false
	ObjInstance.skip_show_anim = true
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _on_TimerSpawn_timeout() -> void :
	_spawn_acidrain()
