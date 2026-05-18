extends KinematicBody2D

signal impact_finished

signal defeated

signal dead_first_phase_anim_ended
signal transform_anim_ended

export var room_l_limit: int
export var room_r_limit: int
export var room_floor_limit: int

var Endgame = preload("res://src/game_objects/bosses/endgame.tscn")
var Scy = preload("res://src/game_objects/enemies_weapons/isaac_scy.tscn")
var Boomerang = preload("res://src/game_objects/enemies_weapons/isaac_boomerang.tscn")
var Bounce = preload("res://src/game_objects/enemies_weapons/isaac_bounce.tscn")

onready var Enemy = $EnemyBase
onready var BossNode = $BossNode
onready var HurtboxEnemy = $Sprite / HurtboxEnemy
onready var TimerNextMove = $TimerNextMove
onready var AnimPlayer = $AnimationPlayer
onready var DetectWallBack = $Sprite / DetectWallBack
onready var DetectWallFront = $Sprite / DetectWallFront

var velocity: = Vector2()

var gravity: int = 2000

var speed: int = 70

var _dashing: bool
var _defeated: bool

var _was_on_floor: bool

func _ready() -> void :
	Enemy.change_state("idle", true)

func _physics_process(delta: float) -> void :
	
	if _dashing == true:
		
		match Enemy.state:
			"walk":
				velocity.x = speed * Enemy.facing
			"walkreverse":
				velocity.x = speed * (Enemy.facing * - 1)
			"fastatk":
				velocity.x = (speed * 4) * Enemy.facing
			"dash":
				velocity.x = (speed * 6) * Enemy.facing
			_:
				velocity.x = 0

	if _dashing == false or Enemy.state in ["idle", "stand", "dead"]:
		velocity.x = 0
	
	if Enemy.state == "walk" and DetectWallFront.is_colliding():
		Enemy.change_direction("inverse")
	elif Enemy.state == "walkreverse" and DetectWallBack.is_colliding():
		Enemy.change_state("walk")

	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if (
		_was_on_floor == false and is_on_floor()
		and Enemy.state == "teleport"
	):
		Enemy.change_state("impact")
	
	_was_on_floor = is_on_floor()

func set_dash(val: bool) -> void :
	_dashing = val

func rumble() -> void :
	Audio.play_sfx("impact_mineral3")
	Audio.play_sfx("explosion_light2")
	VarsGlobal.GameScenario.CameraNode.start_shake(0.4, false, false)
	Gamepad.start_vibration(0, 0.4, 0.4, 0.5)

func snd(val: String) -> void :
	Audio.play_sfx(val)

func position_above_player() -> void :
	global_position.y -= 150
	global_position.x = Enemy.get_player_position().x

func start_battle() -> void :
	Enemy.change_state("idle", true)
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	
	
	Audio.play_music("iron_boss_theme_1", "high", 1)
	yield(get_tree().create_timer(1), "timeout")

	BossNode.start_battle()
	
	Enemy.change_state("idle")
	TimerNextMove.start(2)
	yield(TimerNextMove, "timeout")
	if _defeated == true: return
	
	next_move()

func next_move() -> void :
	randomize()
	if _defeated == false:
		
		spawn_scy()

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state("throw")
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		spawn_scy()

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(2)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkreverse"]))
		TimerNextMove.start(3)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["fastatk", "expand", "dash"]))
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return
		
		spawn_scy()

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkreverse"]))
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		spawn_scy()
		
		for n in randi() % 3:
			Enemy.change_direction("to_player")
			Enemy.change_state("dash", true)
			yield(AnimPlayer, "animation_finished")
			if _defeated == true: return

		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		TimerNextMove.start(1)
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["spin", "throw"]))
		yield(AnimPlayer, "animation_finished")
		if _defeated == true: return

		spawn_scy()

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkreverse"]))
		TimerNextMove.start(rand_range(3, 4))
		yield(TimerNextMove, "timeout")
		if _defeated == true: return
		
		for _n in range(randi() % 3 + 1):
			Enemy.change_direction("to_player")
			Enemy.change_state("teleport", true)
			yield(self, "impact_finished")
			if _defeated == true: return

		if randi() % 2 == 1:
			Enemy.change_direction("to_player")
			Enemy.change_state("expand")
			yield(AnimPlayer, "animation_finished")
			if _defeated == true: return
		
		spawn_scy()

		Enemy.change_direction("to_player")
		Enemy.change_state(RNGTools.pick(["walk", "walkreverse"]))
		TimerNextMove.start(rand_range(3, 4))
		yield(TimerNextMove, "timeout")
		if _defeated == true: return

		next_move()

func spawn_boomerang() -> void :
	var ObjInstance = Boomerang.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = $Sprite / PosThrow.global_position + Vector2(0, 10)
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_bounce() -> void :
	
	if _defeated == true:
		return
	
	var ObjInstance = Bounce.instance()
	ObjInstance.global_position = $Sprite.global_position

	if Enemy.facing == 1:
		ObjInstance.angle_degrees = - 320
	else:
		ObjInstance.angle_degrees = 140
	ObjInstance.dir_play = Enemy.facing
	
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_scy() -> void :
	if _defeated == true:
		return
	randomize()
	var ObjInstance = Scy.instance()
	ObjInstance.global_position = Enemy.get_player_position(
		Vector2(
			RNGTools.pick([ - 70, - 40, 40, 70]), 
			- 30
		)
	)
	ObjInstance.global_position.y -= rand_range(30, 130)
	ObjInstance.target_position = Enemy.get_player_position(Vector2(
		rand_range( - 30, 30), - 20
	))
	ObjInstance.increase_speed = 0.5
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
func goto_two_phase() -> void :
	Enemy.change_direction("to_player")
	Audio.stop_music()
	$GhostTrail.start_trail(0, 0.1)
	AnimPlayer.play("twophase")
	yield(AnimPlayer, "animation_finished")
	Audio.play_sfx("thunder_1")
	VarsGlobal.GameInterface.show_flash()
	var ObjInstance = Endgame.instance()
	ObjInstance.room_l_limit = room_l_limit
	ObjInstance.room_r_limit = room_r_limit
	ObjInstance.room_floor_limit = room_floor_limit
	ObjInstance.global_position = global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
	emit_signal("transform_anim_ended")
	queue_free()

func _transform_elevate() -> void :
	var Tw: = create_tween()
	
	Tw.tween_property(
		self, 
		"global_position", Vector2(316, - 120), 1.5
	)

func snd_teleport_in() -> void :
	$lasershort.play()
	$vlad_spawn_start.play()
func snd_teleport_out() -> void :
	$lasershort3.play()
	$vlad_spawn_end.play()

func clear_atk() -> void :
	get_tree().call_group("isaac_weapon", "queue_free")

func _on_AreaDetectPlayerFacing_area_exited(_area: Area2D) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
	elif Enemy.state == "walkreverse":
		Enemy.change_state("walk")

func _on_EnemyBase_enemy_defeated(_NodeEnemy) -> void :
	set_physics_process(false)
	clear_atk()
	_defeated = true
	emit_signal("defeated")
