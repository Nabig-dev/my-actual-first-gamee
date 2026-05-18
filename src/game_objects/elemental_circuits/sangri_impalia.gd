extends Node2D

var Lance = preload("res://src/game_objects/elemental_circuits/_sangri_impalia_lance.tscn")

var dir: int = 1
var position_spawn: Vector2

var current_extra_damage: int

func _ready() -> void :
	
	VarsGlobal.game_data["player_bl_now"] = FuncsNumbers.decrease_value(
		40, VarsGlobal.game_data["player_bl_now"]
	)
	VarsGlobal.GameInterface.update_hud_values()
	
	position_spawn = global_position
	position_spawn.x += 32 * dir
	_on_TimerSpawn_timeout()
	

func _on_TimerActive_timeout() -> void :
	queue_free()


func _on_TimerSpawn_timeout() -> void :
	position_spawn.x += 16 * dir
	var ObjInstance = Lance.instance()
	ObjInstance.global_position = position_spawn
	ObjInstance.get_node("HitboxPlayer").extra_damage = current_extra_damage
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	ObjInstance.connect("impacted_enemy", self, "_OnEnemyImpact")
	Audio.play_sfx("vlad_lance_impale")
	
	
func _OnEnemyImpact() -> void :
	
	current_extra_damage += VarsGlobal.get_stat("int") / 4
