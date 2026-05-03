extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	if VarsGlobal.has_flag("eztilia34_event_finished") == true:
		pass

func _on_Area2D_area_entered(_area: Area2D) -> void :
	
	if VarsGlobal.has_flag("eztilia34_event_finished") == true:
		return
		
	Audio.stop_music()
		
	var Johannes: KinematicBody2D = VarsGlobal.GameScenario.get_node("EventJohannes/Johannes1")
	
	Johannes.Enemy.change_state("prism")

	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	yield(get_tree().create_timer(1), "timeout")
	
	Audio.play_sfx("ec_absorbing")
	
	Johannes.Enemy.change_direction("1")
	
	VarsGlobal.Player.move(Vector2.RIGHT)
	yield(get_tree().create_timer(1.5), "timeout")
	VarsGlobal.Player.stop_move()
	VarsGlobal.GameScenario.CameraNode.limit_left = 609
	VarsGlobal.GameScenario.get_node("DungeonForgottenTileMap").modulate.a = 0
	VarsGlobal.GameScenario.get_node("DungeonForgottenTileMap").position = Vector2.ZERO

	Audio.play_music("before_johannes")

	
	yield(get_tree().create_timer(2), "timeout")
	Johannes.Enemy.change_state("idle")
	VarsGlobal.GameInterface.show_flash()
	VarsGlobal.GameScenario.get_node("EventJohannes/DemonCore").activate()
	VarsGlobal.GameScenario.get_node("CanvasLayer/Control/NoiseRect").visible = true
	Audio.stop_sfx("ec_absorbing")
	yield(get_tree().create_timer(1), "timeout")
	
	Johannes.Enemy.change_direction("-1")
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.GameInterface.start_dialog("demoncore-ev1")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	yield(get_tree().create_timer(0.5), "timeout")
	Johannes.Enemy.change_state("prepare")
	yield(Johannes.get_node("AnimationPlayer"), "animation_finished")

	yield(get_tree().create_timer(0.5), "timeout")
	VarsGlobal.GameInterface.start_dialog("demoncore-ev2")
	yield(VarsGlobal.GameInterface, "dialog_ended")

	
	VarsGlobal.GameScenario.get_node("CanvasLayer/Control/BatleProgressBar").visible = true
	VarsGlobal.GameScenario.get_node("CanvasLayer/Control/BatleProgressBar").value = 0
	VarsGlobal.GameScenario.get_node("CanvasLayer/Control/BatleProgressBar").max_value = Johannes.max_hits
	Johannes.Enemy.change_state("idle2")
	Johannes.start_battle()
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	
	
	
	


func _on_finish_battle() -> void :

	if VarsGlobal.game_data["player_hp_now"] <= 0:
		return
	VarsGlobal.Player.invencibility(2, false)
	
	Audio.stop_music()
	
	var Johannes: KinematicBody2D = VarsGlobal.GameScenario.get_node("EventJohannes/Johannes1")
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	VarsGlobal.GameInterface.show_flash()
	
	
	VarsGlobal.Player.change_state("crouch")
	VarsGlobal.Player._change_sprite_facing(1)
	VarsGlobal.Player.global_position = VarsGlobal.GameScenario.get_node("EventJohannes/PositionXandriaEvA").global_position
	Johannes.global_position = VarsGlobal.GameScenario.get_node("EventJohannes/PositionJohannesEvA").global_position
	Johannes.Enemy.change_direction("-1")
	Johannes.Enemy.change_state("finisher")
	
	yield(get_tree().create_timer(4), "timeout")
	VarsGlobal.GameInterface.start_dialog("demoncore-ev3")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	
	yield(get_tree().create_timer(0.5), "timeout")
	Johannes.Enemy.change_state("finisher_interrupt")
	
	Audio.play_music("before_johannes")
	
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.GameScenario.get_node("EventJohannes/AnimationPlayer").play("atreu_show")
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.GameInterface.start_dialog("demoncore-ev4")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	yield(get_tree().create_timer(1), "timeout")
	VarsGlobal.GameScenario.get_node("EventJohannes/AnimationPlayer").play("atreu_shoot")
	
	
	VarsGlobal.Player.change_state("idle")
	Audio.play_music("tension_battle", "high", 0)
	Johannes.velocity.x = 0
	Johannes.Enemy.change_state("shield")
	Johannes.get_node("TimerToUltraMegido").start()
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)
	
	Johannes.current_hits = 0
	VarsGlobal.GameScenario.get_node("CanvasLayer/Control/BatleProgressBar").visible = true
	VarsGlobal.GameScenario.get_node("CanvasLayer/Control/BatleProgressBar").value = 0
	VarsGlobal.GameScenario.get_node("CanvasLayer/Control/BatleProgressBar").max_value = Johannes.max_hits
	
	
	
	


func _on_finish_destroy_shield() -> void :
	
	if VarsGlobal.game_data["player_hp_now"] <= 0:
		return
	VarsGlobal.Player.invencibility(2, false)
	
	
	if Config.get_value("video", "vfx_level", 0) == 2:
		VarsGlobal.GameInterface.screen_scaling = true
		VarsGlobal.GameInterface._on_MainViewport_size_changed()
	
	VarsGlobal.GameInterface.show_flash()
	Audio.play_sfx("impact_earth2")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.2)
	Gamepad.start_vibration(0, 0.3, 0.3, 0.3)
	
	Audio.stop_music()
	var Johannes: KinematicBody2D = VarsGlobal.GameScenario.get_node("EventJohannes/Johannes1")
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	VarsGlobal.GameScenario.get_node("EventJohannes/AnimationPlayer").play("atreu_ended_shoot")
	yield(get_tree().create_timer(2.5), "timeout")
	VarsGlobal.GameInterface.show_flash()

	
	VarsGlobal.Player.change_state("idle")
	VarsGlobal.Player._change_sprite_facing(1)
	VarsGlobal.Player.global_position = VarsGlobal.GameScenario.get_node("EventJohannes/PositionXandriaEvA").global_position
	Johannes.global_position = VarsGlobal.GameScenario.get_node("EventJohannes/PositionJohannesEvA").global_position
	Johannes.Enemy.change_direction("-1")
	
	VarsGlobal.GameInterface.start_dialog("demoncore-ev5")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	VarsGlobal.GameInterface.show_quick_text(
		"WATCHOUT", VarsGlobal.GameScenario.get_node("EventJohannes/SpriteAtreu")
	)
	
	
	Johannes.Enemy.change_state("hurt")
	
	VarsGlobal.GameScenario.get_node("EventJohannes/AnimationPlayer").play("atreu_defend")
	yield(get_tree().create_timer(1.5), "timeout")
	
	
	yield(get_tree().create_timer(1), "timeout")
	Engine.set_time_scale(1)
	Audio.play_music("after_johannes")
	VarsGlobal.GameInterface.start_dialog("demoncore-ev6")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	yield(get_tree().create_timer(0.5), "timeout")
	VarsGlobal.GameScenario.get_node("EventJohannes/AnimationPlayer").play("atreu_fall")
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.GameInterface.show_flash()
	VarsGlobal.GameScenario.CameraNode.return_to_player(1)
	var Tw: = create_tween().tween_property(
		VarsGlobal.GameScenario.CameraNode, "zoom", Vector2(1, 1), 1
	)
	yield(Tw, "finished")
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.GameInterface.start_dialog("demoncore-ev7")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	VarsGlobal.GameInterface.show_flash()
	VarsGlobal.GameScenario.get_node("CanvasLayer/Control/NoiseRect").visible = false
	
	Audio.play_sfx("vlad_spawn_end")
	Johannes.queue_free()
	VarsGlobal.GameScenario.get_node("EventJohannes/DemonCore").queue_free()
	VarsGlobal.Player._change_sprite_facing(1)
	yield(get_tree(), "idle_frame")
	yield(get_tree().create_timer(2), "timeout")
	VarsGlobal.Player.change_state("depress", true, false)
	yield(get_tree().create_timer(2), "timeout")
	
	
	
	
	
	var TwRect: = create_tween()
	
	TwRect.tween_property(
		VarsGlobal.GameScenario.get_node("CanvasLayer/Control/ColorRect"), "color", Color.black, 3
	)
	yield(TwRect, "finished")
	
	
	
	
	SceneChanger.change_scene("res://src/screens/end_early_access.tscn")


func _on_finished_events() -> void :
	
	pass


func _on_Johannes1_battle_ended() -> void :
	_on_finish_battle()
func _on_Johannes1_shield_broken() -> void :
	_on_finish_destroy_shield()


func _on_Johannes1_hit_received() -> void :
	VarsGlobal.GameScenario.get_node("CanvasLayer/Control/BatleProgressBar").value += 1
