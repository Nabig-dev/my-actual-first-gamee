extends Node2D

export (
	String, "none", 
	"ahuizote_knife", 
	"ahuizote_molotov", 
	"dzolok", 
	"skeleton_warrior"
) var spawn_enemy = "none"

var enemies: Dictionary = {
	"ahuizote_knife": preload("res://src/game_objects/enemies/ahuizote_with_knife.tscn"), 
	"ahuizote_molotov": preload("res://src/game_objects/enemies/ahuizote_molotov.tscn"), 
	"dzolok": preload("res://src/game_objects/enemies/dzolok.tscn"), 
	"skeleton_warrior": preload("res://src/game_objects/enemies/skeleton_warrior.tscn")
}

export var is_crushed: bool

onready var Anim = $AnimationPlayer

func _ready() -> void :
	
	if is_crushed == false and VarsGlobal.has_flag("prologue_finished") == false:
		Anim.play("fire")
	else:
		set_crushed()

func set_crushed() -> void :
	Anim.stop(true)
	is_crushed = true
	$GrijaylaTavernWindowAnimation.frame = 8

func crush() -> void :
	if is_crushed == false:
		is_crushed = true
		
		Audio.play_sfx("impact_window_break")
		Anim.play("destroyed")
		
		if spawn_enemy != "none":
			var ObjInstance = enemies[spawn_enemy].instance()
			ObjInstance.global_position = $Position2DEnemy.global_position
			VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
