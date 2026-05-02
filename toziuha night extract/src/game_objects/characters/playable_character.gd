extends Node2D

class_name PlayableCharacter, "res://assets/icons/position-stick-man.svg"

signal character_added

var CharInstance = null
var CharXandria = preload("res://src/game_objects/characters/xandria.tscn")
var CharSmolXandria = preload("res://src/game_objects/characters/smol_xandria.tscn")

export var can_move: bool = true

func _ready() -> void :
	
	if get_parent().has_method("_on_Playable_character_added"):
		
		connect("character_added", get_parent(), "_on_Playable_character_added")
	
	visible = false
	
	
	match VarsGlobal.current_player_char:
		"smol_xandria", "maria":
			CharInstance = CharSmolXandria.instance()
		_:
			CharInstance = CharXandria.instance()
	
	CharInstance.global_position = global_position
	
	
	if CharInstance.has_method("set_enabled_input") == true:
		CharInstance.set_enabled_input(can_move)

	
	get_parent().call_deferred("add_child", CharInstance)
	yield(get_tree(), "idle_frame")

	
	if VarsGlobal.GameInterface.first_entry_area == true:
		Input.action_release("ui_left")
		Input.action_release("ui_right")

	
	if is_instance_valid(VarsGlobal.GameInterface) == true:
		if CharInstance.has_signal("dead") == true:
			CharInstance.connect("dead", VarsGlobal.GameInterface, "_on_Player_dead")

	
	var player_idx = CharInstance.get_index()
	var placeholder_idx = get_index()
	get_parent().move_child(self, player_idx)
	get_parent().move_child(CharInstance, placeholder_idx)

	yield(get_tree(), "idle_frame")
	
	emit_signal("character_added")

	queue_free()
