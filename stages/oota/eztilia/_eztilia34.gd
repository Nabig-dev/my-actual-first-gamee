extends Node

var Bullet = preload("res://src/game_objects/weapons/atreu_bullet_cinematic.tscn")

func spawn_bullet() -> void :
	if VarsGlobal.game_data["player_hp_now"] <= 0:
		return
	var ObjInstance = Bullet.instance()
	
	ObjInstance.dir = 1
	ObjInstance.global_position = VarsGlobal.GameScenario.get_node("EventJohannes/PositionBullet").global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func start_atreu_defend() -> void :
	Engine.set_time_scale(0.6)
	VarsGlobal.GameScenario.CameraNode.move_to(
		VarsGlobal.GameScenario.get_node("EventJohannes/SpriteAtreu").global_position + Vector2(200, 0), 1
	)
	create_tween().tween_property(
		VarsGlobal.GameScenario.CameraNode, "zoom", Vector2(0.7, 0.7), 1
	)
func end_atreu_defend() -> void :
	Engine.set_time_scale(1)
	VarsGlobal.GameScenario.CameraNode.return_to_player(1)

func flashimpact() -> void :
	Audio.play_sfx("atreu_stab")
	VarsGlobal.GameInterface.show_flash()
