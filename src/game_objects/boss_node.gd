extends Node

signal defeated_with_no_damage
signal death_animation_ended

export var boss_ide: String

export var hurtbox_node: NodePath

export var battle_song: String = "prepare_for_war"

export var song_fadein: float = 0.0

export var open_doors_on_defeat: bool = true
export var stop_music_on_defeat: bool = true

var _defeated_with_no_damage: bool = true

onready var Tm = $Timer

func _ready() -> void :
	
	
	
	if was_defeated() == true:
		yield(get_tree(), "idle_frame")
		unlock_boss_doors()
		get_parent().queue_free()
		return

	if hurtbox_node.is_empty() == false:
		
		get_node(hurtbox_node).connect("defeated", self, "_on_enemy_defeated")
		
		get_node(hurtbox_node).connect("damaged", self, "_on_enemy_damaged")
	
	
	
	yield(Tm, "timeout")
	
	VarsGlobal.GameInterface.enabled_quicksave = false
	if VarsGlobal.Player != null and VarsGlobal.Player.has_signal("damaged"):
		VarsGlobal.Player.connect("damaged", self, "_on_Player_damaged")
	
	
	VarsGlobal.GameInterface.ControMiniMap.visible = false
	

func start_battle() -> void :
	
	VarsGlobal.GameInterface.can_pause = true
	
	VarsGlobal.Player.set_enabled_input(true)
	
	if battle_song != "":
		Audio.play_music(battle_song, "high", song_fadein)
	
	VarsGlobal.GameInterface.get_node("%BossBar").start_bar(
		get_node(hurtbox_node).data_enemy["health_points"]
	)

	VarsGlobal.GameScenario.boss_battle_active = true
	
	
	VarsGlobal.GameInterface.ControMiniMap.visible = false

func show_title_boss() -> void :
	
	if boss_ide.empty() == true:
		return
	
	var boss_name: String = tr(CSVDBLoader.get_db("enemies")[boss_ide]["name"])
	
	

	
	VarsGlobal.GameInterface.show_boss_title(
		boss_name
	)

func was_defeated() -> bool:
	return VarsGlobal.game_data["flags"].has("defeated_" + boss_ide)

func unlock_boss_doors() -> void :
	for d in get_tree().get_nodes_in_group("doors"):
		if d.type_door == d.TYPES.BOSS:
			
			d.door_locked = false
			
			d.open_door()
			
			d.not_close_again = true

func _on_enemy_damaged() -> void :
	VarsGlobal.GameInterface.get_node("%BossBar").set_value(
		get_node(hurtbox_node).hp_now
	)

func _on_enemy_defeated() -> void :
	
	
	
	VarsGlobal.GameInterface.get_node("%BossBar").hide_bar()
	
	VarsGlobal.GameScenario.emit_signal("boss_defeated")
	
	Audio.play_sfx("boss_death")
	
	if stop_music_on_defeat == true:
		Audio.stop_music("all", 1.0)
	
	if was_defeated() == false:
		VarsGlobal.add_flag("defeated_" + boss_ide)
	
		if _defeated_with_no_damage == true:
			
			
			emit_signal("defeated_with_no_damage")
	
	if open_doors_on_defeat == true:
		unlock_boss_doors()
	
	Tm.start(0.1)
	Engine.time_scale = 0.07
	yield(Tm, "timeout")
	
	
	var Tw = get_tree().create_tween()
	Tw.tween_property(
		Engine, "time_scale", 1.0, 0.7
	)
	yield(Tw, "finished")
	
	
	VarsGlobal.GameScenario.boss_battle_active = false

	
	VarsGlobal.GameInterface.ControMiniMap.visible = true

func _on_Player_damaged() -> void :
	_defeated_with_no_damage = false

func _on_BossNode_death_animation_ended() -> void :
	VarsGlobal.GameScenario.emit_signal("boss_death_animation_ended")

func _on_BossNode_tree_exiting() -> void :
	VarsGlobal.GameInterface.enabled_quicksave = true
