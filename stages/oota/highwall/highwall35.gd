extends Node

var Azche = preload("res://src/game_objects/enemies/azche.tscn")

var camera_limit_l: int
var camera_limit_r: int

var _dialoging: bool

var say_stackback: bool
var say_wegoaura: bool

func _ready() -> void :
	
	
	
	
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.has_flag("aura_rescue_room_boss_defeated") == true:
		VarsGlobal.GameScenario.get_node("NPCAura").queue_free()
		VarsGlobal.GameScenario.get_node("BossAppearCinematic").queue_free()
		VarsGlobal.GameScenario.get_node("BossAppearCinematic").queue_free()
		return
	
	VarsGlobal.GameInterface.connect(
		"dialog_signal_emitted", self, "_on_dialog_signal"
	)
	
	if VarsGlobal.has_flag("aura_rescue_accepted"):
		VarsGlobal.GameScenario.get_node("DoorBoss").quick_open_door()
		VarsGlobal.GameScenario.get_node("DoorBoss2").quick_open_door()
		VarsGlobal.GameScenario.get_node("Area2D2/CollisionShape2D").disabled = false
	
	VarsGlobal.GameScenario.get_node("the_stalker").gravity = 0
	VarsGlobal.GameScenario.get_node("the_stalker").velocity = Vector2.ZERO
	
	camera_limit_l = VarsGlobal.GameScenario.CameraNode.limit_left
	camera_limit_r = VarsGlobal.GameScenario.CameraNode.limit_right
	
	VarsGlobal.GameScenario.get_node("DoorBoss").position.y = - 1000
	VarsGlobal.GameScenario.get_node("DoorBoss2").position.y = - 1000
	
	VarsGlobal.GameScenario.get_node("NPCAura").play("crouch")

	if VarsGlobal.has_flag("aura_impale_snd") == false:
		yield(get_tree().create_timer(1), "timeout")
		VarsGlobal.add_flag("aura_impale_snd")
		Audio.play_sfx("vlad_lance_impale")
		Audio.play_sfx("vlad_spawn_end")
		Audio.play_sfx("axe_hit_blood")

func refresh_dialogic_vars() -> void :
	Dialogic.set_variable(
		"aura_meeted", 
		int(VarsGlobal.has_flag("aura_meeted"))
	)
	Dialogic.set_variable(
		"aura_rescue_accepted", 
		int(VarsGlobal.has_flag("aura_rescue_accepted"))
	)

func _on_Area2D_area_entered(_area: Area2D) -> void :
	
	if (
		VarsGlobal.has_flag("aura_rescue_room_boss_defeated") == true
		and VarsGlobal.has_flag("aura_rescue_accepted") == true
	):
		return
	refresh_dialogic_vars()
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	yield(get_tree().create_timer(2), "timeout")
	
	VarsGlobal.GameInterface.start_dialog("aura-meeting")
	
	yield(VarsGlobal.GameInterface, "dialog_ended")

	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)

func _on_Area2D2_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("aura_rescue_room_boss_defeated") == true:
		return
	
	if VarsGlobal.has_flag("aura_rescue_accepted") == false:
		return
	
	Audio.stop_music()
	
	VarsGlobal.GameScenario.get_node("DoorBoss").position = Vector2(328, - 32)
	VarsGlobal.GameScenario.get_node("DoorBoss2").position = Vector2(8, - 32)
	
	VarsGlobal.GameScenario.get_node("DoorBoss").close_door()
	VarsGlobal.GameScenario.get_node("DoorBoss2").close_door()
	
	
	VarsGlobal.GameScenario.CameraNode.limit_left = - 2
	VarsGlobal.GameScenario.CameraNode.limit_right = 339
	
	yield(get_tree().create_timer(3), "timeout")
	
	Audio.play_music("prepare_for_war", "high", 0)
	
	yield(get_tree().create_timer(2), "timeout")
	
	if say_stackback == false:
		say_stackback = true
		VarsGlobal.GameInterface.show_quick_text(
			"STAYBACKAURA", VarsGlobal.Player, - 75
		)
	
	Audio.play_sfx("ec_charging_enemy")
	VarsGlobal.GameScenario.get_node("BossAppearCinematic/AnimationPlayer").play("show")
	
	VarsGlobal.Player.stop_move()

func _on_boss_defeated(_NodeEnemy) -> void :
	VarsGlobal.add_flag("aura_rescue_room_boss_defeated")
	
	VarsGlobal.GameScenario.CameraNode.limit_left = camera_limit_l
	VarsGlobal.GameScenario.CameraNode.limit_right = camera_limit_r
	VarsGlobal.GameScenario.get_node("TimerSpawnAzche").stop()
	

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void :
	
	VarsGlobal.GameInterface.show_flash()
	
	Audio.stop_sfx("ec_charging_enemy")
	Audio.play_sfx("vlad_spawn_start")
	
	VarsGlobal.GameScenario.get_node("the_stalker").global_position = VarsGlobal.GameScenario.get_node(
		"BossAppearCinematic/ElementalCircuit"
	).global_position
	VarsGlobal.GameScenario.get_node("the_stalker").gravity = 250
	
	VarsGlobal.GameScenario.get_node("the_stalker/EnemyBase").change_direction("to_player")
	
	VarsGlobal.GameScenario.get_node("BossAppearCinematic").queue_free()
	
	yield(get_tree().create_timer(1), "timeout")
	
	VarsGlobal.GameScenario.get_node("the_stalker/EnemyBase").connect(
		"enemy_defeated", self, "_on_boss_defeated"
	)
	
	VarsGlobal.GameScenario.start_boss_battle()
	VarsGlobal.GameScenario.get_node("TimerSpawnAzche").start(10)
	

func _on_TimerSpawnAzche_timeout() -> void :
	if VarsGlobal.GameScenario.boss_battle_active == false:
		return
	if get_tree().get_nodes_in_group("azche").size() > 0:
		return
	var ObjInstance = Azche.instance()
	ObjInstance.global_position = VarsGlobal.GameScenario.get_node("the_stalker").global_position - Vector2(0, 170)
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _on_Area2D3_area_entered(_area: Area2D) -> void :
	if VarsGlobal.has_flag("aura_rescue_room_boss_defeated") == true:
		return
	VarsGlobal.GameInterface.show_quick_text(
		"WHATFCKHAPPENEDHERE", VarsGlobal.Player, - 75
	)

func _on_dialog_signal(_dialog_name, signal_name: String) -> void :
	if signal_name == "aura_rescue_accepted":
		VarsGlobal.add_flag("aura_rescue_accepted")
		Savedata.update_flag_game("aura_rescue_accepted")
		
		VarsGlobal.GameScenario.get_node("NPCAura").play("idle")
		
		VarsGlobal.GameScenario.get_node("DoorBoss").quick_open_door()
		VarsGlobal.GameScenario.get_node("DoorBoss2").quick_open_door()
		
		VarsGlobal.GameScenario.get_node("Area2D2/CollisionShape2D").disabled = false
		
		if say_stackback == false:
			say_stackback = true
			VarsGlobal.GameInterface.show_quick_text(
				"STAYBACKAURA", VarsGlobal.Player, - 75
			)
	if signal_name == "aura_meeted":
		VarsGlobal.add_flag("aura_meeted")
		Savedata.update_flag_game("aura_meeted")

func _on_Node_tree_exiting() -> void :
	Audio.stop_sfx("ec_charging_enemy")

func _on_InteractableArea2DIndicator_interact_requested() -> void :
	if _dialoging == true or VarsGlobal.has_flag("aura_rescue_accepted") and say_wegoaura == false:
		say_wegoaura = true
		VarsGlobal.GameInterface.show_quick_text(
			"WEGOAURA", VarsGlobal.Player, - 75
		)
		return
	_dialoging = true
	_on_Area2D_area_entered(Area2D.new())
	yield(VarsGlobal.GameInterface, "dialog_ended")
	_dialoging = false
