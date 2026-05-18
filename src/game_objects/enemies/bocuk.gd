extends KinematicBody2D

var Frigus = preload("res://src/game_objects/enemies_weapons/frigus_bocuk.tscn")

var speed: int = 40
var velocity: Vector2
var chase_move: bool

var _target: Vector2

onready var Enemy = $EnemyBase
onready var VisibEnabler = $VisibilityEnabler2D
onready var AreaDetectPlayer = $AreaDetectPlayer
onready var Tw = $Tween
onready var Spr = $Sprite
onready var Spr2 = $Sprite / SpriteOutline

func _ready() -> void :
	$AnimationPlayer2.play("outline")

func _physics_process(_delta: float) -> void :
	if (
		VisibEnabler.is_on_screen() == true
		and chase_move == true
		and Enemy.state == "fly"
	):
		
		Enemy.change_direction("to_player")
		
		
		velocity = Vector2.ZERO
		
		velocity = global_position.direction_to(
			Enemy.get_player_position(Vector2(0, - 45))
		) * speed
	
	velocity = move_and_slide(velocity)

func _set_target() -> void :
	Enemy.change_direction("to_player")
	_target = Enemy.get_player_position(Vector2(0, - 30))

func spawn_frigus_horizontal(auto_target: bool = true, angle: float = 0.0) -> void :
	Audio.play_sfx("ec_ice_start")
	var ObjInstance = Frigus.instance()
	ObjInstance.global_position = $Sprite / Position2DZ.global_position
	ObjInstance.auto_target = false
	ObjInstance.angle_variation = angle
	if auto_target == false:
		ObjInstance.speed = 300
		ObjInstance.target_position = $Sprite / Position2DZ2.global_position
	else:
		ObjInstance.target_position = _target
	
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func return_to_chase(with_random_tween: bool = true) -> void :
	randomize()
	var distance: float = 40
	var player_pos_y: float = Enemy.get_player_position().y - 70
	
	if Enemy.get_player_distance() > 200:
		distance = 10
	
	tween_stop()
	Enemy.change_state("fly", true)
	Enemy.change_direction("to_player")
	if with_random_tween == true:
		tween_to(
			RNGTools.pick([
				Vector2(global_position.x - distance, player_pos_y), 
				Vector2(global_position.x + distance, player_pos_y), 
				Vector2(global_position.x + distance, player_pos_y), 
				Vector2(global_position.x - distance, player_pos_y), 
			]), 1
		)
		yield(Tw, "tween_completed")
	chase_move = true

func tween_stop() -> void :
	Tw.remove_all()
	Tw.stop_all()

func tween_to(target: Vector2, time: float = 0.5) -> void :
	if Enemy.state in ["dead"]:
		return
	
	Enemy.change_direction("to_player")
	tween_stop()
	
	Tw.interpolate_property(
		self, 
		"global_position", 
		global_position, 
		target, 
		time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	
	Tw.start()

func _set_pos_y_equal_player() -> void :
	tween_to(
		Vector2(
			global_position.x, VarsGlobal.Player.global_position.y - 10
		), 1
	)

func _on_TimerStartActive_timeout() -> void :
	return_to_chase(false)

func _on_AreaDetectPlayer_object_entered(_Obj) -> void :
	
	if $VisibilityEnabler2D.is_on_screen() == false:
		return
	
	chase_move = false
	velocity = Vector2.ZERO
	randomize()
	
	if Enemy.state == "fly":
		Enemy.change_direction("to_player")
		Enemy.change_state(
			RNGTools.pick(["attack", "attack2"])
		)
		if Enemy.state == "attack2":
			_set_pos_y_equal_player()
		else:
			Audio.play_sfx("eva_laugh")

func _on_TimerRepeatAtk_timeout() -> void :
	if AreaDetectPlayer.is_colliding() == true:
		AreaDetectPlayer.emit_signal("object_entered", Node.new())

func _on_EnemyBase_enemy_defeated(_NodeEnemy) -> void :
	chase_move = false
	tween_to(
		global_position + Vector2(0, 80), 3
	)

func _on_Sprite_frame_changed() -> void :
	Spr2.frame = Spr.frame
