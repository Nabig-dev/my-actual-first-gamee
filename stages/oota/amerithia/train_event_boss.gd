extends Node

var BossBat = preload("res://src/game_objects/bosses/giant_bat.tscn")

func _ready() -> void :
	
	Audio.play_music("before_dirian_sheal")
	yield(get_tree().create_timer(0.3), "timeout")
	
	VarsGlobal.GameInterface.connect(
		"boss_orb_obtained", self, "_on_boss_orb_obtained"
	)
	
	
	if VarsGlobal.game_data["difficulty_base"] == 0:
		VarsGlobal.GameScenario.get_node("DungeonForgottenTileMap2").position = Vector2.ZERO
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.Player.stop_move()
	VarsGlobal.Player.move(Vector2.LEFT)
	yield(get_tree().create_timer(1.5), "timeout")
	VarsGlobal.Player.stop_move()
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.GameInterface.start_dialog("sheal-in-train")
	yield(VarsGlobal.GameInterface, "dialog_ended")

	
	VarsGlobal.GameScenario.get_node("Sheal").Enemy.change_state("invoke")
	
	VarsGlobal.GameScenario.get_node("AnimationPlayer").play("changesky")
	
	yield(get_tree().create_timer(2), "timeout")
	Audio.play_sfx("spell_prepare")
	
	
	var ObjInstance = BossBat.instance()
	ObjInstance.global_position = VarsGlobal.GameScenario.get_node("Position2D").global_position
	ObjInstance.get_node("Sprite/HurtboxEnemy").connect(
		"defeated", self, "_on_boss_defeated"
	)
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
	
	yield(get_tree().create_timer(1.5), "timeout")
	
	VarsGlobal.GameInterface.show_flash("flash", Color.white)
	VarsGlobal.GameScenario.get_node("Sheal").queue_free()
	Audio.play_sfx("vlad_spawn_start")
	
	ObjInstance.start_battle()
	
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	
func _on_boss_orb_obtained() -> void :
	
	if VarsGlobal.game_data["player_hp_now"] > 0:
		VarsGlobal.GameScenario.get_node("CanvasLayer/AnimationPlayer").play("fadeout")
		VarsGlobal.GameInterface.can_pause = false
		Audio.play_sfx("train_end")
		yield(VarsGlobal.GameScenario.get_node("CanvasLayer/AnimationPlayer"), "animation_finished")
		SceneChanger.change_scene("res://stages/oota/aridiah/aridiah_station.tscn")

func _on_boss_defeated() -> void :
	VarsGlobal.GameScenario.get_node("DungeonForgottenTileMap2").position = Vector2.ZERO
	Achievments.obtain_ach("ach3")
	VarsGlobal.GameInterface.can_pause = false
	yield(get_tree().create_timer(1), "timeout")
	
	
	VarsGlobal.GameInterface.Node2DMap.add_mark( - 1, [ - 24, - 2])
	
	VarsGlobal.add_flag("train_event_finished")
	
	
