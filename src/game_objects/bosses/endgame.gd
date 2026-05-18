extends KinematicBody2D

var ScyCricle = preload("res://src/game_objects/enemies_weapons/scy_circle.tscn")
var Scy = preload("res://src/game_objects/enemies_weapons/isaac_scy.tscn")
var Boomerang = preload("res://src/game_objects/enemies_weapons/isaac_boomerang.tscn")
var Skull = preload("res://src/game_objects/enemies/floating_skull.tscn")

export var room_l_limit: int
export var room_r_limit: int
export var room_floor_limit: int

var speed: int = 50
var velocity: Vector2
var _idle_chase: bool
var _chase: bool
var _y_direction: int = - 1
var _position_y_teleport: float

var _original_position: Vector2

var _defeated: bool

onready var Enemy = $EnemyBase
onready var AnimPlayer = $AnimationPlayer
onready var TimerNextMove = $TimerNextMove

func _ready() -> void :
	Enemy.change_state("idle", true)
	yield(get_tree().create_timer(0.5), "timeout")
	_original_position = global_position

		
		

func _physics_process(_delta: float) -> void :
	if Enemy.state == "idle" and _idle_chase == true:
		
		velocity.x = 0
		velocity.x = global_position.direction_to(
			Enemy.get_player_position()
		).x * speed
		
		velocity.y = 30 * _y_direction
	elif Enemy.state == "chase" and _chase == true:
		Enemy.change_direction("to_player")
		
		velocity = Vector2.ZERO
		velocity = global_position.direction_to(
			Enemy.get_player_position(Vector2(0, - 30))
		) * (speed * 1.5)
	elif Enemy.state == "attack_power":
		Enemy.change_direction("to_player")
		
		velocity.y = 0
		velocity.y = global_position.direction_to(
			Enemy.get_player_position()
		).y * speed
	else:
		velocity = Vector2.ZERO
	
	velocity = move_and_slide(velocity)

func start_battle() -> void :
	$TimerSpawnScy.start(3)
	Audio.play_music("iron_boss_theme_2")
	$BossNode.start_battle()
	next_move()

func next_move() -> void :
	if _defeated == true:
		return
	
	var _2nd_phase = _defeated
	
	randomize()
	
	idle_chase()
	
	TimerNextMove.start(rand_range(1, 3))
	yield(TimerNextMove, "timeout")
	if _2nd_phase == true: return

	stop_idle_chase()
	
	yield(return_to_og_position(), "finished")
	TimerNextMove.start(2)
	yield(TimerNextMove, "timeout")
	if _2nd_phase == true: return
	
	Enemy.change_direction("to_player")
	Enemy.change_state("chase")
	yield(AnimPlayer, "animation_finished")
	_set_chase(false)
	if _2nd_phase == true: return
	
	Enemy.change_direction("to_player")
	Enemy.change_state(RNGTools.pick(["attack_power", "boomerangs"]))
	yield(AnimPlayer, "animation_finished")
	if _2nd_phase == true: return
	
	idle_chase()
	TimerNextMove.start(1)
	yield(TimerNextMove, "timeout")
	if _2nd_phase == true: return

	yield(return_to_og_position(), "finished")
	TimerNextMove.start(2)
	yield(TimerNextMove, "timeout")
	if _2nd_phase == true: return

	Enemy.change_direction("to_player")
	Enemy.change_state(RNGTools.pick(["spawn", "scyatk"]))
	yield(AnimPlayer, "animation_finished")
	if _2nd_phase == true: return
	
	idle_chase()
	TimerNextMove.start(1)
	yield(TimerNextMove, "timeout")
	if _2nd_phase == true: return

	yield(return_to_og_position(), "finished")
	TimerNextMove.start(1)
	yield(TimerNextMove, "timeout")
	if _2nd_phase == true: return
	
	next_move()

func snd(val: String) -> void :
	Audio.play_sfx(val)

func idle_chase() -> void :
	Enemy.change_state("idle", true)
	_idle_chase = true
	$TimerZigzag.start(1)
func stop_idle_chase() -> void :
	_idle_chase = false
	$TimerZigzag.stop()

func spawn_boomerangs() -> void :
	_spawn_boomerang($ElementalCircuit.global_position, - 1)
	_spawn_boomerang($ElementalCircuit2.global_position)

func _spawn_boomerang(pos_to_spawn: Vector2, dir: int = 1) -> void :
	var ObjInstance = Boomerang.instance()
	ObjInstance.dir = dir
	ObjInstance.global_position = pos_to_spawn
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _set_chase(val: bool) -> void :
	_chase = val

func spawn_scycircle(scale_x: int = 1) -> void :
	var ObjInstance = ScyCricle.instance()
	ObjInstance.global_position = $PositionCenter.global_position
	ObjInstance.scale.x = scale_x
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_skull() -> void :
	var ObjInstance = Skull.instance()
	ObjInstance.global_position = $PositionCenter.global_position
	ObjInstance.z_index = 2
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_scy() -> void :
	
	if (
		get_tree().get_nodes_in_group("isaac_boomerang").size() > 0
		or Enemy.state in ["spawn", "scyatk"]
	):
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
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func spawn_scy_atk() -> void :
	randomize()
	var ObjInstance = Scy.instance()
	var Positions: Array = $Sprite / PositionsScy.get_children()
	
	ObjInstance.global_position = RNGTools.pick(Positions).global_position
	ObjInstance.global_position += Vector2(
		rand_range( - 10, 10), 
		rand_range( - 10, 10)
	)
	ObjInstance.target_position = Enemy.get_player_position(Vector2(
		rand_range( - 30, 30), - 20
	))
	ObjInstance.steer_force = 20
	ObjInstance.speed = ObjInstance.speed / 2
	ObjInstance.auto_target = true
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
func _teleport_hide_position() -> void :
	_position_y_teleport = Enemy.get_player_position().y
	global_position.y = - 1000
func _teleport_to_side(dir: int = 0) -> void :
	randomize()
	if dir == 0:
		dir = randi() % 2 + 1
	if dir == 1:
		global_position.x = room_r_limit
	else:
		global_position.x = room_l_limit

	global_position.y = RNGTools.pick(
		[room_floor_limit, room_floor_limit - 50]
	)
	Enemy.change_direction("to_player")
func _move_teleport_side() -> void :
	var Tw: = create_tween()
	
	Tw.tween_property(
		self, "global_position:x", 
		global_position.x + (300 * Enemy.facing), 0.4
	)

func return_to_og_position() -> SceneTreeTween:
	var Tw: = create_tween()
	
	Tw.tween_property(
		self, "global_position", _original_position, 1
	)
	return Tw

func move_to_floor_position() -> void :
	var Tw: = create_tween()
	
	Tw.tween_property(
		self, "global_position", Vector2(global_position.x, room_floor_limit), 1
	)

func _on_TimerAutoFacing_timeout() -> void :
	if Enemy.state in ["idle"]:
		Enemy.change_direction("to_player")

func _on_TimerZigzag_timeout() -> void :
	if Enemy.state in ["idle"]:
		_y_direction = _y_direction * - 1
	else:
		$TimerZigzag.stop()

func _on_TimerAutoStart_timeout() -> void :
	start_battle()

func _on_TimerSpawnScy_timeout() -> void :
	spawn_scy()
	randomize()
	$TimerSpawnScy.start(rand_range(2, 3))
