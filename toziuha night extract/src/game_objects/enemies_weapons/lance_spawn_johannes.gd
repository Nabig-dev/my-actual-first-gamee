extends Node2D

var Lance = preload("res://src/game_objects/enemies_weapons/top_lance_johannes.tscn")

func _ready() -> void :
	Audio.play_sfx("crystal_soul_generating2")
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")
	spawn()
	$AnimationPlayer.play_backwards("show")
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func spawn() -> void :
	Audio.play_sfx("spell_shoot4")
	Audio.play_sfx("shoot_projectile_arrow")
	Audio.play_sfx("ec_shoot_fast")
	var ObjInstance = Lance.instance()
	ObjInstance.global_position = global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
