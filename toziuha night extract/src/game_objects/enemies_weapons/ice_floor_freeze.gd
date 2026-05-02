extends Node2D

var Freeze = preload("res://src/game_objects/enemies_weapons/player_freeze.tscn")

func _ready() -> void :
	$ColorRect.visible = false

func showfloor() -> void :
	Audio.play_sfx("ec_pasive_activate")
	Audio.play_sfx("ui_quickitem_use")
	Audio.play_sfx("ec_ice_start2")
	$AnimationPlayer.play("show")

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	var ObjInstance = Freeze.instance()
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
