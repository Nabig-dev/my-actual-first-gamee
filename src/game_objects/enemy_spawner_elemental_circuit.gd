extends Node2D

signal enemy_spawned(EnemyScene)

export var auto_start: bool = true
export var enemy_scene_name: String = "skeleton"

var EnemyScene

var EnemyInstanceSpawned

func _ready() -> void :
	EnemyScene = load("res://src/game_objects/enemies/%s.tscn" % [enemy_scene_name])
	if auto_start == true:
		start_anim()

func start_anim() -> void :
	Audio.play_sfx("spell_prepare3")
	$AnimationPlayer.play("spawn")

func spawn_enemy() -> void :
	var ObjInstance = EnemyScene.instance()
	ObjInstance.global_position = global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	Audio.play_sfx("floating_sword_prepared")
	emit_signal("enemy_spawned", ObjInstance)
	EnemyInstanceSpawned = ObjInstance
