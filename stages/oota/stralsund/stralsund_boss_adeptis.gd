extends Node

var _defeated_no_damage: bool

func _ready() -> void :

	yield(get_tree().create_timer(0.3), "timeout")
	
	VarsGlobal.GameScenario.get_node("RoomChanger3").position = Vector2(340, - 1000)
	
	VarsGlobal.GameScenario.get_node("Boss/CanvasLayer/FadeWhite").color = Color("#00ffffff")
	
	if VarsGlobal.has_flag("defeated_boss_alessandro1") == false:
		Audio.play_music("before_cavendish")
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.set_enabled_input(false)
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.Player.stop_move()
		VarsGlobal.Player.move(Vector2.RIGHT)
		yield(get_tree().create_timer(2.5), "timeout")
		VarsGlobal.Player.stop_move()
		yield(get_tree().create_timer(2), "timeout")
		VarsGlobal.GameInterface.start_dialog("alessandro_1_meet")
		yield(VarsGlobal.GameInterface, "dialog_ended")
		VarsGlobal.GameScenario.get_node("Boss/Alessandro1").start_battle()
		yield(get_tree().create_timer(2), "timeout")
		VarsGlobal.GameInterface.can_pause = true
		VarsGlobal.Player.set_enabled_input(true)

	
	else:
		remove_intact_floor()


func remove_intact_floor() -> void :
	VarsGlobal.GameScenario.get_node("FloorDestroyed/FloorIntact").queue_free()
	VarsGlobal.GameScenario.get_node("FloorDestroyed/StaticBody2D/CollFloorDestroyed").disabled = false
	
	VarsGlobal.GameScenario.get_node("RoomChanger3").position = Vector2(340, - 59)

func _on_Alessandro1_battle_ended() -> void :
	
	if VarsGlobal.game_data["player_hp_now"] <= 0:
		return
	
	Achievments.obtain_ach("ach4")
	Audio.play_music("after_cavendish")
	VarsGlobal.Player.change_state("idle", true, false)
	
	
	VarsGlobal.GameScenario.get_node("Boss/Annette1").Enemy.change_state("novisible")
	
	VarsGlobal.Player.invencibility(3, false)
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.stop_move()
	VarsGlobal.Player.set_enabled_input(false)
	
	var Tw: = get_tree().create_tween()
	
	
	Tw.tween_property(
		VarsGlobal.GameScenario.get_node("Boss/CanvasLayer/FadeWhite"), 
		"color", Color.white, 2
	)
	yield(Tw, "finished")
	
	
	
	VarsGlobal.GameScenario.get_node("Boss/Alessandro1").global_position = VarsGlobal.GameScenario.get_node(
		"Boss/PositionsAfterBattle/PosAlessandro"
	).global_position
	
	VarsGlobal.Player.global_position = VarsGlobal.GameScenario.get_node(
		"Boss/PositionsAfterBattle/PosXandria"
	).global_position
	
	VarsGlobal.GameScenario.get_node("Boss/Alessandro1/Sprite").frame = 54
	
	VarsGlobal.Player.move(Vector2.RIGHT)
	yield(get_tree().create_timer(0.5), "timeout")
	VarsGlobal.Player.stop_move()
	
	yield(get_tree().create_timer(2), "timeout")
	
	Tw = get_tree().create_tween()
	
	Tw.tween_property(
		VarsGlobal.GameScenario.get_node("Boss/CanvasLayer/FadeWhite"), 
		"color", Color("#00000000"), 0.5
	)
	yield(Tw, "finished")
	
	yield(get_tree().create_timer(2), "timeout")
	
	
	VarsGlobal.GameScenario.get_node("Boss/Annette1").visible = false
	VarsGlobal.GameScenario.get_node("Boss/Annette1").global_position = VarsGlobal.GameScenario.get_node(
		"Boss/PositionsAfterBattle/PosAnnette"
	).global_position
	
	
	VarsGlobal.GameScenario.get_node(
		"Boss/PositionsAfterBattle/PosAnnette/ParticlesTeleport"
	).emitting = true
	
	Audio.play_sfx("crystal_soul_generating")
	
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.GameScenario.get_node("Boss/Annette1").visible = true
	VarsGlobal.GameScenario.get_node(
		"Boss/PositionsAfterBattle/PosAnnette/ParticlesTeleport"
	).emitting = false
	VarsGlobal.GameScenario.get_node("Boss/Annette1").Enemy.change_state("teleport_in")
	Audio.stop_sfx("crystal_soul_generating")
	
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.GameScenario.get_node("Boss/Annette1").Enemy.change_state("idle")
	
	yield(get_tree().create_timer(4), "timeout")
	
	VarsGlobal.GameInterface.start_dialog("annette_appear")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	yield(get_tree().create_timer(2), "timeout")
	VarsGlobal.GameScenario.get_node("Boss/Annette1").Enemy.change_state("explosion")
	
	yield(get_tree().create_timer(0.5), "timeout")
	VarsGlobal.Player.move(Vector2.LEFT)
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.Player.move(Vector2.RIGHT)
	yield(get_tree().create_timer(0.1), "timeout")
	VarsGlobal.Player.stop_move()


func _on_Annette1_explosion_exploted() -> void :
	
	VarsGlobal.GameScenario.get_node("Boss/Alessandro1").BossNode.unlock_boss_doors()
	
	Audio.play_sfx("lasershort3")
	Audio.play_sfx("vlad_spawn_end")
	
	remove_intact_floor()
	
	VarsGlobal.GameScenario.get_node("Boss").queue_free()
	VarsGlobal.GameInterface.show_flash("flash", Color.white)
	
	if _defeated_no_damage == true:
		if VarsGlobal.GameScenario.get_node_or_null("Treasure") != null:
			VarsGlobal.GameScenario.get_node("Treasure").global_position = VarsGlobal.GameScenario.get_node("Position2DTreasure").global_position
	
	yield(get_tree().create_timer(2), "timeout")
	
	
	VarsGlobal.GameInterface.start_dialog("alessandro1_battleended")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)

	
	




func _on_BossNode_defeated_with_no_damage() -> void :
	_defeated_no_damage = true
