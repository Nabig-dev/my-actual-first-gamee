extends Node

var Bat = preload("res://src/game_objects/enemies/bat.tscn")
var Balor = preload("res://src/game_objects/enemies/balor.tscn")

export var active: bool = true

export (
	String, 
	"bat", "balor"
) var enemy = "bat"

export (
	String, 
	"-1", "1", "auto"
) var direction_to_move = "auto"

export var time_spawn: float = 0.5
export var max_spawns: int = 3

export var limit_top: int = - 10000000
export var limit_bottom: int = 10000000
export var limit_left: int = - 10000000
export var limit_right: int = 10000000

var _total_spawned: int

var _direction: int

func _ready() -> void :
	$TimerSpawn.start(1)

func spawn() -> void :

	if (
		active == false
		or _total_spawned >= max_spawns
		or is_player_off_limit() == true
	):
		return

	randomize()
	var pos_to_spawn: = get_position_outside_camera()
	pos_to_spawn.y += rand_range( - 16, 32)
	
	
	var ObjInstance: Object
	
	if enemy == "bat":
		ObjInstance = Bat.instance()
	elif enemy == "balor":
		ObjInstance = Balor.instance()
		ObjInstance.pattern = "flying"
	
	ObjInstance.global_position = pos_to_spawn
	ObjInstance.dir_x = _direction
	
	
	ObjInstance.connect("tree_exiting", self, "_on_EnemyDefeated")
	ObjInstance.get_node("HurtboxEnemy").connect("defeated", self, "_on_EnemyDefeated")
	
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
	_total_spawned += 1

func is_player_off_limit() -> bool:
	var player_pos: Vector2 = VarsGlobal.Player.global_position
	if (
		player_pos.x > limit_right or player_pos.x < limit_left
		or 
		player_pos.y < limit_top or player_pos.y > limit_bottom
	):
		return true
	else:
		return false

func is_player_near_to_camera_limit(treshold: float = 180) -> bool:
	var CameraNode: Camera2D = VarsGlobal.GameScenario.CameraNode
	var player_pos_x: float = VarsGlobal.Player.global_position.x
	var distance_to_limit_l: float = abs(
		abs(player_pos_x) - abs(CameraNode.limit_left)
	)
	var distance_to_limit_r: float = abs(
		abs(player_pos_x) - abs(CameraNode.limit_right)
	)
	
	if (
		(_direction == - 1 and distance_to_limit_r < treshold)
		or (_direction == 1 and distance_to_limit_l < treshold)
	):
		return true
	
	else:
		return false

func get_position_outside_camera() -> Vector2:
	
	var offset_x: int = 64
	var result: Vector2
	var camera_pos: Vector2 = VarsGlobal.GameScenario.CameraNode.get_camera_position()
	
	
	
	if direction_to_move != "auto":
		_direction = int(_direction)
	else:
		_direction = VarsGlobal.Player.facing * - 1
	
	
	if is_player_near_to_camera_limit() == true:
		_direction = _direction * - 1
	
	if _direction == - 1:
		result = Vector2(
			camera_pos.x + (170 + offset_x), 
			VarsGlobal.Player.global_position.y
		)
	
	else:
		result = Vector2(
			camera_pos.x - (170 + offset_x), 
			VarsGlobal.Player.global_position.y
		)

	return result

func _on_EnemyDefeated() -> void :
	_total_spawned -= 1

func _on_TimerSpawn_timeout() -> void :
	spawn()
	randomize()
	$TimerSpawn.start(
		rand_range(time_spawn, time_spawn + 1)
	)
