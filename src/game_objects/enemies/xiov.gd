extends KinematicBody2D

var WaterBall = preload("res://src/game_objects/enemies_weapons/water_ball.tscn")
var Slash = preload("res://src/game_objects/enemies_weapons/aeria_slash.tscn")

var speed: int = 55
var velocity: Vector2
var chase_move: bool

onready var Enemy = $EnemyBase
onready var VisibEnabler = $VisibilityEnabler2D
onready var Tw = $Tween
onready var PositionSlash = $Sprite / PositionSlash

func _ready() -> void :
	$AnimFlyMove.play("fly")

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

func _snd_startatk() -> void :
	Audio.play_sfx("kryvon_startatk")
func _slash() -> void :
	Audio.play_sfx("sword_slash_slow2")

func spawn_slash() -> void :
	var ObjInstance = Slash.instance()
	ObjInstance.global_position = PositionSlash.global_position
	ObjInstance.dir = Enemy.facing
	ObjInstance.get_node("AeriaSlash").scale.y = 0.5
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_waterball() -> void :
	var ObjInstance = WaterBall.instance()
	ObjInstance.global_position = global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func play_explosion() -> void :
	Audio.play_sfx("explosion_light3")

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

func return_to_chase(with_random_tween: bool = true) -> void :
	randomize()
	var distance: float = 80
	var player_pos_y: float = Enemy.get_player_position().y - 80
	
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

func _set_pos_y_equal_player() -> void :
	if VisibEnabler.is_on_screen() and Enemy.get_player_distance() < 250:
		tween_to(
			Vector2(
				global_position.x, VarsGlobal.Player.global_position.y - 10
			), 1
		)

func _on_TimerActive_timeout() -> void :
	return_to_chase(false)


func _on_TimerRepeatAtk_timeout() -> void :
	randomize()
	$TimerRepeatAtk.start(
		rand_range(2, 6)
	)
	
	if (
		Enemy.state == "fly"
		and VisibEnabler.is_on_screen() == true
	):
		velocity = Vector2.ZERO
		chase_move = false
		Enemy.change_direction("to_player")
		if Enemy.get_player_distance() < 100:
			Enemy.change_state("attack_a")
		else:
			Enemy.change_state("attack_b")







func _on_Timer_timeout() -> void :
	randomize()
	$Timer.start(rand_range(4, 5))
	if (
		Enemy.state == "fly"
		and VisibEnabler.is_on_screen() == true
	):
		spawn_waterball()
