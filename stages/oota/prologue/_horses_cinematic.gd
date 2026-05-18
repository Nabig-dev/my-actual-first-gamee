extends Node

export var speed: int = 1500
export var dir: int = 1

var motion: Vector2

onready var ForestBG = $QuietForestBG
onready var FloorParallax = $FloorParallax

func _ready() -> void :
	Audio.play_music("ambient_forest_wind")
	Audio.play_sfx("horse_galloping_loop")
	$AnimationPlayer.play("show")

func _process(delta: float) -> void :
	
	motion = Vector2( - speed, 0)
	motion *= delta
	
	ForestBG.scroll_offset += motion * dir
	FloorParallax.scroll_offset += motion * dir

func play_end() -> void :
	$AnimationPlayer.play("end")
	yield($AnimationPlayer, "animation_finished")
	SceneChanger.change_scene("res://stages/oota/grijayla/grijayla_entrance.tscn")


func _on_Node2D_tree_exiting() -> void :
	
	Audio.stop_sfx("horse_galloping_loop", true, 3)
	
