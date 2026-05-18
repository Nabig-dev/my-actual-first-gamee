tool 

extends Node2D

signal sacrifice_completed
signal sacrifice_completed_realtime

enum TYPES{BOSS, SACRIFICE, BRONZE_KEY, SILVER_KEY, GOLDEN_KEY}

export (TYPES) var type_door = TYPES.BRONZE_KEY setget _update_type

export var door_locked: bool = true

export var ide_sacrifice_door: String

export var sacrificies_needed: int

export var ide_boss: String

var is_opened: bool = false

var not_close_again: bool = false

onready var TimerReady = $TimerReady
onready var Anim = $AnimationPlayer

func _ready() -> void :
	
	if Engine.is_editor_hint() == false:
		get_node("%SolidTop").disabled = true
		get_node("%SolidBottom").disabled = true
		
		
		
		if (
			type_door == TYPES.BOSS
			and ide_boss.empty() == false
			and VarsGlobal.game_data["flags"].has("defeated_" + ide_boss)
		):
			quick_open_door()
			
			get_node("AreaDetectPlayer").disconnect("area_entered", self, "_on_AreaDetectPlayer_area_entered")
			get_node("AreaDetectPlayer").disconnect("area_exited", self, "_on_AreaDetectPlayer_area_exited")

func quick_open_door() -> void :
	$Top.position.y = - 64
	$Bottom.position.y = 0
	$Center.modulate.a = 0
	is_opened = true

func open_door() -> void :
	if is_opened == false:
		is_opened = true
		Anim.play("open")
		
		Audio.play_sfx("door_boss_open")

func close_door() -> void :
	if is_opened == true:
		is_opened = false
		Anim.play_backwards("open")
		
		
		if SceneChanger.changing_scene == false:
			
			Audio.play_sfx("door_boss_open")

func _is_key_obtained() -> bool:
	var is_obtained: bool = true
	match type_door:
		0:
			
			is_obtained = not door_locked
		1:
			
			if door_locked == true and sacrificies_needed > 0 and ide_sacrifice_door.empty() == false:
				is_obtained = false
		2:
			is_obtained = VarsGlobal.game_data["player_key_objects"].has(
				GVar.KEYS_OBJECTS.BRONZE_KEY
			)
		3:
			is_obtained = VarsGlobal.game_data["player_key_objects"].has(
				GVar.KEYS_OBJECTS.SILVER_KEY
			)
		4:
			is_obtained = VarsGlobal.game_data["player_key_objects"].has(
				GVar.KEYS_OBJECTS.GOLD_KEY
			)
		
	return is_obtained

func _update_type(type: int) -> void :
	type_door = type
	$Top.frame = type_door
	$Bottom.frame = type_door
	name = "Door" + str(
		TYPES.keys()[type_door]
	).capitalize().replace(" ", "")

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	if Engine.is_editor_hint() == true:
		return
	
	
	if TimerReady.is_stopped() == false:
		quick_open_door()
		return

	if _is_key_obtained() == true and is_opened == false:
		open_door()

func _on_AreaDetectPlayer_area_exited(_area: Area2D) -> void :
	if Engine.is_editor_hint() == true:
		return
	
	
	if type_door == TYPES.SACRIFICE and sacrificies_needed <= 0 and is_opened == true:
		return
	
	if not_close_again == false:
		close_door()

func _on_TimerReady_timeout() -> void :
	if Engine.is_editor_hint() == true:
		return
	
	get_node("%SolidTop").disabled = false
	get_node("%SolidBottom").disabled = false
	
	VarsGlobal.GameScenario.connect("enemy_defeated", self, "_on_EnemyDefeated")
	
	
	if type_door == TYPES.SACRIFICE and ide_sacrifice_door.empty() == false:
		if VarsGlobal.has_flag("door_sacrifice_unlocked_" + ide_sacrifice_door):
			emit_signal("sacrifice_completed")
			sacrificies_needed = 0
			quick_open_door()

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void :
	if is_opened == false:
		
		Audio.play_sfx("door_boss_close")
	
func _on_EnemyDefeated(_enemy_ide: String) -> void :
	if type_door != TYPES.SACRIFICE or ide_sacrifice_door.empty() == true:
		return
	
	sacrificies_needed -= 1

	if sacrificies_needed < 1:
		door_locked = false
		VarsGlobal.add_flag("door_sacrifice_unlocked_" + ide_sacrifice_door)
		emit_signal("sacrifice_completed_realtime")
		if is_opened == false:
			open_door()
