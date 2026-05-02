extends Node2D

var Fire = preload("res://src/game_objects/enemies_weapons/simple_fire.tscn")

var fire_instance: bool = true

var makedmg: bool = true

func _ready() -> void :
	if makedmg == false:
		$HitboxEnemy / CollisionShape2D.shape = null
		$HitboxEnemy / CollisionShape2D2.shape = null
	Audio.play_sfx("explosion_clean")
	$AnimationPlayer.play("show")

func spawn_fire() -> void :
	if fire_instance == true and VarsGlobal.game_data["difficulty_base"] > 0:
		var FireInst = Fire.instance()
		FireInst.global_position = global_position
		VarsGlobal.GameScenario.add_child(FireInst)
