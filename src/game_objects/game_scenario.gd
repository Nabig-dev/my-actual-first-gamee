extends Node

class_name GScenario, "res://assets/icons/blueprint.png"

signal enemy_defeated(enemy_id)
signal character_ready

signal boss_defeated

signal boss_death_animation_ended

signal circuit_obtained

signal blood_spend

var DamageNumber = preload("res://src/game_objects/damage_number_indicator.tscn")
var HitsSparks = preload("res://src/game_objects/vfx/hits_sparks_impact.tscn")
var HitsLines = preload("res://src/game_objects/vfx/hit_lines_impact.tscn")
var BloodDrop = preload("res://src/game_objects/vfx/blood_drop.tscn")

export (
	String, 
	"silence", "beginning_of_darkness", 
	"beginning_of_darkness_underground", 
	"beginning_of_darkness_underwater", 
	"afternoon_ruins", "rest_town", 
	"grey_woods", "the_order", 
	"stralsund_ruins", "athos_abbey", "birstall", 
	"birstall_normal", "the_sinkhole", 
	"tahuatepet_volcano", "tahuatepet_underwater", "the_barrens", 
	"train_assault"
) var music = "silence"

export var low_music_mode: bool = false

export (
	String, 
	"none", 
	"heat", 
	"cold"
) var thermal_condition = "none"

export var sound_reverb: bool = false
export var active_camera: = true
export var camera_follow_player: = true

var reparented: = false

var boss_battle_active: bool

var _damage_number_instance = null
var _hits_sparks_instance = null
var _hits_lines_instance = null
var _blood_drop_instance = null

var _camera_limits: = []

onready var WorldEnv = $WorldEnvironment
onready var CameraNode = $Camera

func _ready() -> void :

	Audio.set_enabled_reverb(sound_reverb)
	
	
	if thermal_condition != "none":
		
		if ThermalBar.is_active() == true:
			ThermalBar.mode_stat = "add"
		
		else:
			ThermalBar.start(thermal_condition)
	
	elif thermal_condition == "none" and ThermalBar.is_active() == true:
		
		ThermalBar.mode_stat = "minus"
	
	
	
	if Config.get_value("video", "aditional_glow", false) == false:
		WorldEnv.environment = null
	else:
		WorldEnv.environment.glow_enabled = true

	VarsGlobal.GameScenario = self
	
	if low_music_mode == true:
		Audio.play_music(music, "low")
	else:
		Audio.play_music(music)

	
	var _camera_limit = get_tree().get_nodes_in_group("camera_limit")
	if _camera_limit.empty() == false:
		CameraNode.set_limits(_camera_limit[0])
	
	if VarsGlobal.has_flag("lux_tenebris_started", 1) == true:
		ElementalCircuits.spawn_action_circuit(
			GVar.EC_ACTION.LUX_TENEBRIS, Vector2.ZERO
		)

func start_teleport(where: int = 1) -> void :
	Audio.play_sfx("vlad_spawn_start")
	get_node("TeleportVfx/AnimationPlayer").play("show")
	get_node("TeleportVfx").global_position = VarsGlobal.Player.global_position
	yield(
		get_node("TeleportVfx/AnimationPlayer"), "animation_finished"
	)
	VarsGlobal.GameInterface.show_flash()
	get_node("TeleportVfx").visible = false
	VarsGlobal.Player.visible = false
	yield(get_tree().create_timer(0.1), "timeout")
	Audio.play_sfx("vlad_spawn_end")
	
	
	if where == 0:
		if VarsGlobal.game_data["last_save_room_used"] != "":
			SceneChanger.change_scene(
				VarsGlobal.game_data["last_save_room_used"]
			)
		else:
			SceneChanger.change_scene(
				get_tree().current_scene.filename
			)
	else:
		VarsGlobal.current_room_changer = ""
		VarsGlobal.current_building_door = ""
		VarsGlobal.game_data.current_room_changer = ""
		VarsGlobal.game_data.current_building_door = ""
		SceneChanger.change_scene("res://stages/oota/the_core/amerithia_central.tscn")

func start_boss_battle() -> void :
	for b in get_tree().get_nodes_in_group("boss"):
		if b.has_method("start_battle"):
			VarsGlobal.GameInterface.can_pause = false
			VarsGlobal.Player.set_enabled_input(false)
			VarsGlobal.Player.velocity.x = 0
			b.start_battle()

func cancel_quick_menu_use() -> void :
	VarsGlobal.GameScenario.get_node("%QuickMenuItemStatus").cancel_use()

func get_facing_pointing_to(node: Object, target_node: Object) -> int:
	if node.global_position.x > target_node.global_position.x:
		return 1
	else:
		return - 1

func show_damage_number(
	damage: int = 0, 
	glob_pos: Vector2 = Vector2.ZERO, 
	color: String = "neutral", 
	critic: bool = false
) -> void :
	_damage_number_instance = DamageNumber.instance()
	add_child(_damage_number_instance)
	_damage_number_instance.show_number(damage, glob_pos, color, critic)
	_damage_number_instance = null
	

func show_hit(
	name_hit: String, dir_x: int = 1, glob_pos: Vector2 = Vector2.ZERO
) -> void :
	_hits_sparks_instance = HitsSparks.instance()
	add_child(_hits_sparks_instance)
	_hits_sparks_instance.show_hit(name_hit, dir_x, glob_pos)
	_hits_sparks_instance = null

func show_hit_lines(
	name_hit: String, dir_x: int = 1, glob_pos: Vector2 = Vector2.ZERO
) -> void :
	_hits_lines_instance = HitsLines.instance()
	_hits_lines_instance.global_position = glob_pos
	_hits_lines_instance.scale.x = dir_x
	_hits_lines_instance.anim_name = name_hit
	add_child(_hits_lines_instance)
	_hits_lines_instance = null

func spawn_blood_drop(pos: Vector2) -> void :
	_blood_drop_instance = BloodDrop.instance()
	_blood_drop_instance.global_position = pos
	add_child(_blood_drop_instance)

func _on_Camera_positioned_on_player() -> void :
	VarsGlobal.GameInterface.hide_blackrect()

func _on_GameScenario_tree_exiting() -> void :
	if reparented:
		VarsGlobal.GameScenario = null

func _on_Playable_character_added() -> void :
	CameraNode.current = active_camera
	CameraNode.follow_player = camera_follow_player
	emit_signal("character_ready")

func _on_TimerEnableSmooth_timeout() -> void :
	CameraNode.smoothing_enabled = true
