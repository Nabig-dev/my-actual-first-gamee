extends Node


export var parent_sprite_path: = NodePath()

export var sprite_path: = NodePath()

export var modulate_ghost: = Color("4f9cf6")


export var scale_from_parent: = true


export var use_custom_z_index: bool
export var z_index: int = 0

var sprite_ghost = preload("res://src/game_objects/ghost_trail_sprite.tscn")
var sprite_ghost_instance = null

var enabled: bool = true

var _self_parent = null
var _parent_sprite = null
var _original_sprite = null

onready var TimerTrail = $TimeTrail
onready var TimerBGhosts = $TimeBetweenGhosts

func _ready() -> void :
	_self_parent = get_parent()
	_parent_sprite = get_node_or_null(parent_sprite_path)
	_original_sprite = get_node_or_null(sprite_path)

func start_trail(duration: float = 0.0, in_between: float = 0.2) -> void :
	if enabled == false:
		return
	
	TimerTrail.stop()
	TimerBGhosts.stop()
	if duration > 0.0:
		TimerTrail.start(duration)
	TimerBGhosts.start(in_between)

func stop_trail() -> void :
	TimerBGhosts.stop()

func _on_TimeTrail_timeout() -> void :
	stop_trail()


func _on_TimeBetweenGhosts_timeout() -> void :
	
	
	sprite_ghost_instance = sprite_ghost.instance()
	
	sprite_ghost_instance.modulate = modulate_ghost
	
	
	sprite_ghost_instance.texture = _original_sprite.texture
	sprite_ghost_instance.hframes = _original_sprite.hframes
	sprite_ghost_instance.vframes = _original_sprite.vframes
	sprite_ghost_instance.frame = _original_sprite.frame
	sprite_ghost_instance.frame_coords = _original_sprite.frame_coords
	sprite_ghost_instance.global_position = _original_sprite.global_position
	sprite_ghost_instance.flip_h = _original_sprite.flip_h
	sprite_ghost_instance.flip_v = _original_sprite.flip_v
	sprite_ghost_instance.scale = _original_sprite.scale
	sprite_ghost_instance.rotation_degrees = _original_sprite.rotation_degrees
	sprite_ghost_instance.offset = _original_sprite.offset
	sprite_ghost_instance.centered = _original_sprite.centered
	sprite_ghost_instance.scale = _original_sprite.scale
	
	if use_custom_z_index:
		sprite_ghost_instance.z_index = z_index
	else:
		sprite_ghost_instance.z_index = _original_sprite.z_index - 1
		
	
	if scale_from_parent:
		sprite_ghost_instance.scale = sprite_ghost_instance.scale * _self_parent.scale
		sprite_ghost_instance.rotation_degrees = sprite_ghost_instance.rotation_degrees * sprite_ghost_instance.scale.x
	
	
	
	
	
	if VarsGlobal.GameScenario != null:
		VarsGlobal.GameScenario.call_deferred("add_child", sprite_ghost_instance)
	else:
		call_deferred("add_child", sprite_ghost_instance)
