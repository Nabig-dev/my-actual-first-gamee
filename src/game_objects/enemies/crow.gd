extends KinematicBody2D

signal moved_to_rand_pos

var Feather = preload("res://src/game_objects/enemies_weapons/feather_crown.tscn")

var speed: int = 300
var velocity: Vector2

var _is_chasing: bool
var _is_chasing_slow: bool
var _last_player_pos: Vector2

var _moving_rand_pos: bool
var _spawning_feathers: bool

onready var Enemy = $EnemyBase
onready var Tw = $Tween
onready var TimerRepeatAtk = $TimerRepeatAtk
onready var VisibNotifier = $VisibilityNotifierCameraArea
onready var SpriteOriginal = $Sprite
onready var SpriteCopy = $Sprite / Sprite2
onready var PosFeathers = $Sprite / PosFeathers

func _ready() -> void :
	Enemy.change_state("idle", true)
	SpriteCopy.material = SpriteCopy.material.duplicate()
	SpriteOriginal.connect("frame_changed", self, "_on_Sprite_frame_changed")

func _physics_process(_delta: float) -> void :
	
	if Enemy.state in ["dead", "idle"] or Tw.is_active():
		return
	
	if _is_chasing == true:
		Enemy.change_direction("to_player")
		velocity = global_position.direction_to(
			_last_player_pos
		) * speed
		
		if global_position.distance_to(_last_player_pos) < 10:
			velocity = Vector2.ZERO
			Enemy.state = "fly"
			to_fly()
			return
	
	elif _is_chasing_slow == true or VisibNotifier.is_on_screen() == false:
		_last_player_pos = Enemy.get_player_position(Vector2(0, - 40))
		Enemy.change_direction("to_player")
		velocity = global_position.direction_to(
			_last_player_pos
		) * (speed * 0.1)
		
		if global_position.distance_to(_last_player_pos) < 10:
			velocity = Vector2.ZERO
			Enemy.state = "fly"
			to_fly()
			return
	
	else:
		velocity = Vector2.ZERO

	velocity = move_and_slide(velocity)

func _crow_snd() -> void :
	Audio.play_sfx("crow")

func spawn_feathers() -> void :
	Audio.play_sfx("sword_slash_light")
	for n in range(3):
		var ObjInstance = Feather.instance()
		ObjInstance.global_position = PosFeathers.global_position
		match n:
			1:
				ObjInstance.angle_variation = 45
			2:
				ObjInstance.angle_variation = - 45
		VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func set_chase(val: bool) -> void :
	_last_player_pos = Vector2.ZERO
	_is_chasing = val
	Enemy.change_direction("to_player")
	
	if val == true or Enemy.state != "attack":
		velocity = Vector2.ZERO
		_last_player_pos = Enemy.get_player_position(Vector2(0, - 30))
	else:
		velocity = Vector2.ZERO
		

func to_fly() -> void :
	if Enemy.state != "attack":
		Enemy.change_state("fly", true)
		_is_chasing_slow = true
	randomize()
	if TimerRepeatAtk.is_stopped() == true:
		TimerRepeatAtk.start(rand_range(0.5, 1))

func move_to_rand_pos() -> void :

	if Enemy.state in ["idle", "dead", "attack"]:
		return
		
	randomize()
	
	Enemy.change_direction("to_player")
	
	var pos_to_move: Vector2
	var range_to_move: float
	
	if _is_player_up() == true:
		$NextRndMovePos / Pos.position.x = - 60
		if Enemy.facing == - 1:
			range_to_move = rand_range(0, 90)
		else:
			range_to_move = rand_range(90, 180)
	else:
		$NextRndMovePos / Pos.position.x = - 30
		if Enemy.facing == 1:
			range_to_move = rand_range(180, 270)
		else:
			range_to_move = rand_range(270, 360)

	$NextRndMovePos.rotation_degrees = range_to_move
	pos_to_move = $NextRndMovePos / Pos.global_position
	
	Tw.remove_all()
	Tw.stop_all()
	
	Tw.interpolate_property(
		self, 
		"global_position", 
		global_position, 
		pos_to_move, 
		1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	
	Tw.start()
	
	yield(Tw, "tween_completed")
	if Enemy.state == "fly":
		emit_signal("moved_to_rand_pos")

func _is_player_up() -> bool:
	if (
		global_position.y
		< Enemy.get_player_position(Vector2(0, - 80)).y
	):
		return false
	else:
		return true

func _on_Area2DDetectPlayer_area_entered(_area: Area2D) -> void :
	if Enemy.state == "idle":
		_crow_snd()
		to_fly()

func _on_Sprite_frame_changed() -> void :
	SpriteCopy.frame = SpriteOriginal.frame


func _on_TimerRepeatAtk_timeout() -> void :
	if Enemy.state != "fly":
		return
	randomize()
	move_to_rand_pos()
	yield(self, "moved_to_rand_pos")
	var atks: Array = ["attack_a", "attack_b"]
	Enemy.change_state(RNGTools.pick(atks))
	Enemy.state = "attack"
	velocity = Vector2.ZERO
	_is_chasing = false
	_is_chasing_slow = false
	Tw.stop_all()

func _on_attack_end() -> void :
	Enemy.state = "fly"
	to_fly()
