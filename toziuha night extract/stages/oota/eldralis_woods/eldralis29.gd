extends Node

var original_limit_l: float
var original_limit_r: float

func _ready() -> void :
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.has_flag("eldralis_elisia_meet") == true:
		VarsGlobal.GameScenario.get_node("FrigusElisia").queue_free()
		VarsGlobal.GameScenario.get_node("FrigusElisia2").queue_free()
		VarsGlobal.GameScenario.get_node(
			"ElisiaAndAhuizotes"
		).queue_free()
		VarsGlobal.GameScenario.get_node(
			"AhuizoteBurningAlchemist"
		).play_anim("empty")
		
		VarsGlobal.GameScenario.get_node(
			"AhuizoteWithKnife"
		).global_position = VarsGlobal.GameScenario.get_node(
				"AhuizoteBurningAlchemist"
			).global_position - Vector2(30, 0)
		
		if VarsGlobal.GameScenario.get_node_or_null("KeyObject") != null:
			VarsGlobal.GameScenario.get_node("KeyObject").position = VarsGlobal.GameScenario.get_node(
				"AhuizoteBurningAlchemist"
			).position
		return

	
	original_limit_l = VarsGlobal.GameScenario.CameraNode.limit_left
	original_limit_r = VarsGlobal.GameScenario.CameraNode.limit_right
	
	Audio.stop_music()
	
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	
	Audio.play_music("before_elisia")
	
	VarsGlobal.GameScenario.CameraNode.move_to(
		VarsGlobal.GameScenario.get_node(
			"ElisiaAndAhuizotes/Elisia"
		).global_position, 6
	)
	
	yield(get_tree().create_timer(7), "timeout")
	
	
	VarsGlobal.GameInterface.start_dialog("elisia-event-a")
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	
	Audio.play_sfx("whoosh_fire")
	VarsGlobal.GameScenario.get_node(
		"AhuizoteBurningAlchemist/ExplosionParticlesSmall"
	).emitting = true
	
	yield(get_tree().create_timer(1), "timeout")
	
	VarsGlobal.GameInterface.show_flash()
	
	Audio.play_sfx("fire_burning_loop")
	Audio.play_sfx("woman_scream")
	VarsGlobal.GameScenario.get_node(
		"AhuizoteBurningAlchemist"
	).play_anim("burning")
	
	yield(get_tree().create_timer(3), "timeout")
	
	VarsGlobal.GameScenario.CameraNode.return_to_player(3)
	
	
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.Player.move(Vector2.RIGHT)
	
	yield(get_tree().create_timer(2.7), "timeout")
	
	VarsGlobal.Player.stop_move()
	yield(get_tree().create_timer(0.5), "timeout")
	
	VarsGlobal.GameScenario.CameraNode.move_to(
		VarsGlobal.GameScenario.get_node(
			"ElisiaAndAhuizotes/Position2D"
		).global_position, 1
	)
	
	yield(VarsGlobal.GameScenario.CameraNode, "tweened_to_position")
	
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.GameInterface.start_dialog("elisia-event-b")
	get_tree().paused = false
	yield(VarsGlobal.GameInterface, "dialog_ended")
	
	VarsGlobal.GameScenario.get_node(
		"ElisiaAndAhuizotes/Elisia"
	).Enemy.change_state("plasma")
	
	yield(get_tree().create_timer(2), "timeout")
	
	Audio.play_sfx("ec_ice_start")
	VarsGlobal.GameScenario.get_node(
		"ElisiaAndAhuizotes/AnimationPlayer"
	).play("show")
	
	yield(get_tree().create_timer(0.7), "timeout")
	Audio.play_sfx("ec_ice_end")
	Audio.play_sfx("explosion_light2")
	
	
	yield(
		VarsGlobal.GameScenario.get_node(
			"ElisiaAndAhuizotes/AnimationPlayer"
		), "animation_finished"
	)
	
	yield(get_tree().create_timer(2), "timeout")
	
	
	VarsGlobal.GameScenario.get_node(
		"AhuizoteWithKnife/HurtboxEnemy"
	).connect("defeated", self, "_on_ahuizote_defeated")
	
	VarsGlobal.GameInterface.show_flash()
	Audio.play_sfx("vlad_spawn_start")
	Audio.play_sfx("vlad_spawn_end")
	VarsGlobal.GameScenario.get_node(
		"ElisiaAndAhuizotes"
	).queue_free()
	
	
	VarsGlobal.GameScenario.get_node(
		"AhuizoteWithKnife"
	).global_position = VarsGlobal.GameScenario.get_node(
			"AhuizoteBurningAlchemist"
		).global_position - Vector2(30, 0)
	
	Audio.play_music("prepare_for_war")
	VarsGlobal.GameScenario.CameraNode.return_to_player(0.5)
	VarsGlobal.GameScenario.CameraNode.limit_left = 256
	VarsGlobal.GameScenario.CameraNode.limit_right = 600
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)

func _on_ahuizote_defeated() -> void :
	VarsGlobal.add_flag("eldralis_elisia_meet")
	Audio.stop_sfx("fire_burning_loop")
	Audio.play_music("before_elisia")
	VarsGlobal.GameInterface.show_flash()
	Audio.play_sfx("ec_ice_end")
	Audio.play_sfx("explosion_light2")
	Audio.play_sfx("impact_mineral")
	VarsGlobal.GameScenario.get_node("FrigusElisia").queue_free()
	VarsGlobal.GameScenario.get_node("FrigusElisia2").queue_free()
	VarsGlobal.GameScenario.CameraNode.limit_left = original_limit_l
	VarsGlobal.GameScenario.CameraNode.limit_right = original_limit_r
	VarsGlobal.GameScenario.get_node(
		"AhuizoteBurningAlchemist"
	).play_anim("burned")
	
	VarsGlobal.GameScenario.get_node("KeyObject").position = VarsGlobal.GameScenario.get_node(
		"AhuizoteBurningAlchemist"
	).position - Vector2(0, 50)
	yield(get_tree(), "idle_frame")
	VarsGlobal.GameScenario.get_node("KeyObject").mode = RigidBody2D.MODE_RIGID



func _on_Node_tree_exiting() -> void :
	Audio.stop_sfx("fire_burning_loop")


func _on_KeyObject_obtained() -> void :
	VarsGlobal.GameInterface.start_dialog("elisia-event-c")
