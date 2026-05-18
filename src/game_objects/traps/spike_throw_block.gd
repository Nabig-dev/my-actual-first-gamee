tool 
extends Node2D

var Arrow = preload("res://src/game_objects/traps/spike_throw_arrow.tscn")

export (String, "up", "down", "left", "right") var direction = "right" setget set_dir


func set_dir(dir: String) -> void :
	direction = dir
	match direction:
		"up":
			rotation_degrees = - 90
		"right":
			rotation_degrees = 0
		"left":
			rotation_degrees = - 180
		"down":
			rotation_degrees = 90

func start_spawn_arrow() -> void :
	if $AnimationPlayer.is_playing() == false:
		Audio.play_sfx("ui_changed_value2")
		$AnimationPlayer.play("spawn")

func spawn_arrow() -> void :
	Audio.play_sfx("shoot_projectile_arrow")
	Audio.play_sfx("woosh_throw")
	var ObjInstance = Arrow.instance()
	
	ObjInstance.global_position = global_position
	
	match direction:
		"up":
			ObjInstance.direction = Vector2.UP
		"right":
			ObjInstance.direction = Vector2.RIGHT
		"left":
			ObjInstance.direction = Vector2.LEFT
		"down":
			ObjInstance.direction = Vector2.DOWN
	
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
