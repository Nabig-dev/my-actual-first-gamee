extends Node2D

var Pilar = preload("res://src/game_objects/elemental_circuits/_frigus_pilar_pilar.tscn")

var dir: int = 1

var _max_pilar: int = 8
var _now_pilar: int
var _rotation_pilar: float

onready var TimerFree = $TimerFree
onready var TimerSpawnPilar = $TimerSpawnPilar
onready var ElementalCircuit = $ElementalCircuit

func _ready() -> void :
	scale.x = dir
	ElementalCircuit.AnimPlayer.playback_speed = 2
	_on_TimerSpawnPilar_timeout()

func _on_ElementalCircuit_absorbed_anim_end() -> void :
	queue_free()

func _on_TimerSpawnPilar_timeout() -> void :
	if _now_pilar < _max_pilar:
		var pilar_instance = Pilar.instance()
		pilar_instance.rotation_degrees = _rotation_pilar
		add_child(pilar_instance)
		_rotation_pilar += 25
		_now_pilar += 1
	else:
		TimerSpawnPilar.stop()
		TimerFree.start()

func _on_TimerFree_timeout() -> void :
	ElementalCircuit.AnimPlayer.playback_speed = 0.5
	ElementalCircuit.AnimPlayer.play("absorbed")
