extends Area2D

var WaterSplashParticle = preload("res://src/game_objects/vfx/water_splash.tscn")


export var is_char_head: bool

var _water_splash_instance: Object = null

var _player_entered: bool

var _use_custom_splash_color: bool
var _water_splash_color: Gradient

onready var TimerSplashMove = $TimerSplashMove


func _ready() -> void :
	
	for t in get_tree().get_nodes_in_group("water_area_tilemap"):
		if t.custom_splash_color != null:
			_use_custom_splash_color = true
			_water_splash_color = t.custom_splash_color

func _process(_delta: float) -> void :
	if (
		_player_entered == true and 
		is_char_head == false and 
		(
			Input.is_action_just_pressed("jump")
			or Input.is_action_just_pressed("ui_focus_prev")
			or Input.is_action_just_pressed("ui_left")
			or Input.is_action_just_pressed("ui_right")
		)
	):
		TimerSplashMove.start()

func _player_has_method() -> bool:
	if VarsGlobal.Player != null and VarsGlobal.Player.has_method("change_physics_params"):
		return true
	else:
		return false

func _splash_vfx(amount_particles: int = 80, pos_offset: Vector2 = Vector2.ZERO) -> void :
	var new_position = VarsGlobal.Player.global_position + pos_offset
	
	_water_splash_instance = WaterSplashParticle.instance()
	_water_splash_instance.amount = amount_particles
	_water_splash_instance.global_position = new_position
	
	
	if _use_custom_splash_color == true:
		_water_splash_instance.color_ramp = _water_splash_color
	
	VarsGlobal.GameScenario.call_deferred("add_child", _water_splash_instance)

func _on_AreaDetectWater_body_entered(body: Node) -> void :

	if _player_has_method() == false:
		return
	
	_player_entered = true
	
	if is_char_head:
		if body.change_music_mode == true:
			Audio.change_music_style("low")
		ThermalBar.mode_stat = "add"
		ThermalBar.start("underwater")
		VarsGlobal.Player.change_physics_params("water")
		Audio.underwater_filter_enabled(true)
	else:
		Audio.play_sfx("water_splash_in")
		_splash_vfx(80, Vector2(0, 10))
		TimerSplashMove.start()

	if is_char_head == true and VarsGlobal.has_flag("tuto_swiming") == false:
		VarsGlobal.add_flag("tuto_swiming")
		VarsGlobal.GameInterface.start_dialog("about-water")

func _on_AreaDetectWater_body_exited(body: Node) -> void :
	if _player_has_method() == false:
		return
	
	_player_entered = false
	
	if is_char_head:
		if body.change_music_mode == true:
			Audio.change_music_style("high")
		ThermalBar.mode_stat = "minus"
		VarsGlobal.Player.change_physics_params("normal")
		Audio.underwater_filter_enabled(false)
	else:
		Audio.play_sfx("water_splash_out")
		_splash_vfx(80, Vector2(0, - 7))
		TimerSplashMove.stop()

func _on_TimerSplashMove_timeout() -> void :
	if abs(VarsGlobal.Player.velocity.x) != 0 and VarsGlobal.Player.physics_param == "normal":
		if Audio.sound_nodes["water_splash_move"].is_playing() == false:
			Audio.play_sfx("water_splash_move")
		_splash_vfx(5, Vector2(0, - 15))
	else:
		TimerSplashMove.stop()
