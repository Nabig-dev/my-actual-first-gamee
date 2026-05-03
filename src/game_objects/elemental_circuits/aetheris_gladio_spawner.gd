extends Node2D

var Aetheris = preload("res://src/game_objects/elemental_circuits/_aetheris_gladio.tscn")

export var max_spawn: int = 1
var _spawned: int = 0
var _dir: int = 1

func start(maxspawn: int = 1, scalex: int = 1) -> void :
	if $TimerSpawn.is_stopped() == false:
		Audio.play_sfx("ui_incorrect")
		return
	_spawned = 0
	_dir = scalex
	max_spawn = maxspawn
	if max_spawn > 1:
		$TimerSpawn.start()
	_on_TimerSpawn_timeout()

func spawn() -> void :
	var ObjInstance = Aetheris.instance()
	ObjInstance.global_position = global_position
	ObjInstance.scale.x = _dir
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _on_TimerSpawn_timeout() -> void :
	_spawned += 1
	spawn()
	if _spawned >= max_spawn:
		$TimerSpawn.stop()
