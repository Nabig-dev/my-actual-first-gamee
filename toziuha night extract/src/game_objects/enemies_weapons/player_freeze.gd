extends Node2D

var Player: KinematicBody2D

var _freezed: bool = true

var _shakes: int = 0

var _last_player_position: Vector2

func _ready() -> void :
	Player = VarsGlobal.Player
	_last_player_position = Player.global_position
	
	Player.connect("dead", self, "_on_player_death")
	$AnimationPlayer.play("freeze")
	freeze()
	
func freeze() -> void :
	Audio.play_sfx("ec_ice_start")
	Player.is_freezed = true
	Player.set_process(false)
	Player.change_state("idle", true, false)
	if "AnimTree" in Player:
		Player.AnimTree.active = false
	else:
		Player.AnimPlayer.stop()

func unfreeze() -> void :
	Audio.play_sfx("impact_wall")
	Audio.play_sfx("impact_mineral")
	_freezed = false
	Player.is_freezed = false
	Player.set_process(true)
	$AnimationPlayer.play("destroy")
	if "AnimTree" in Player:
		Player.AnimTree.active = true
	
func shake() -> void :
	$AnimationPlayer2.play("shake")
	Audio.play_sfx("ice_shake")
	Audio.play_sfx("ice_shake2")
	_shakes += 1
	if _shakes > 30:
		unfreeze()

func _physics_process(_delta: float) -> void :
	
	if _freezed == false:
		return
	
	
	Player.velocity = Vector2.ZERO
	Player.global_position = _last_player_position
	
	global_position = VarsGlobal.Player.global_position
	
	if (
		Input.is_action_just_pressed("ui_left")
		or Input.is_action_just_pressed("ui_right")
		or Input.is_action_just_pressed("ui_up")
		or Input.is_action_just_pressed("ui_down")
	):
		shake()
	
func _on_player_death() -> void :
	Player.disconnect("dead", self, "_on_player_death")
	unfreeze()
	yield(get_tree(), "idle_frame")
	if "anim_state_machine" in Player:
		Player.anim_state_machine.start("dead")
	elif "AnimPlayer" in Player:
		Player.AnimPlayer.play("dead")
	
