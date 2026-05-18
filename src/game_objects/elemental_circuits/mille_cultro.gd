extends Node2D

var Knife = preload("res://src/game_objects/elemental_circuits/_mille_cultro_Knife.tscn")

var knife_instance: Object = null

var dir: int = 1

var _knifes_spawned: int = 0

onready var ElementalCircuit = $ElementalCircuit
onready var PositionKnife = $PositionKnife
onready var TimerSpawnKnife = $TimerSpawnKnife

func _ready() -> void :
	
	$AnimationPlayer.play("move_pos")
	ElementalCircuit.AnimPlayer.playback_speed = 4
	

func _on_ElementalCircuit_absorbed_anim_end() -> void :
	queue_free()

func _on_TimerSpawnKnife_timeout() -> void :
	
	knife_instance = Knife.instance()
	knife_instance.global_position = PositionKnife.global_position
	knife_instance.dir = dir
	
	VarsGlobal.GameScenario.call_deferred("add_child", knife_instance)
	
	Audio.play_sfx("ec_shoot_fast")
	
	_knifes_spawned += 1
	
	if _knifes_spawned == 25:
		ElementalCircuit.AnimPlayer.playback_speed = 0.5
		TimerSpawnKnife.stop()
		ElementalCircuit.AnimPlayer.play("absorbed")
