extends Node2D

var spawn_active_l: bool
var spawn_active_r: bool

var can_spawn: bool = true setget update_can_spawn

var FireColumn = preload("res://src/game_objects/enemies_weapons/fire_column.tscn")

var ThermitTw: SceneTreeTween

var is_active: bool

onready var PosA = $PositionA
onready var PosB = $PositionB
onready var ThermitParticles = $ThermitParticles
onready var ParticlesSpotlight = $ThermitParticles / Spotlight

func _ready() -> void :
	ParticlesSpotlight.visible = false
	ThermitTw = get_tree().create_tween()
	ThermitTw.stop()

func update_can_spawn(val: bool) -> void :
	can_spawn = val
	if val == false:
		ThermitParticles.emitting = false

func spawn(dir: int = 1) -> void :
	
	is_active = true
	
	var start: float = PosA.global_position.x
	var end: float = PosB.global_position.x
	
	
	if (
		(dir == 1 and spawn_active_l == true)
		or (dir == - 1 and spawn_active_r == true)
	):
		return

	if dir == - 1:
		var temp: float = start
		start = end
		end = temp
	
	if dir == 1:
		spawn_active_l = true
	else:
		spawn_active_r = true
	
	if ThermitTw.is_running() == true:
		ThermitTw.stop()
	
	ThermitParticles.global_position = get_position_outside_area(dir * - 1)
	ThermitParticles.emitting = true
	ParticlesSpotlight.visible = true
	
	ThermitTw = get_tree().create_tween()
	
	ThermitTw.tween_property(
		ThermitParticles, "global_position", 
		get_position_outside_area(dir), 1
	)
	
	yield(ThermitTw, "finished")
	
	ThermitParticles.emitting = false
	ParticlesSpotlight.visible = false
	
	for x in range(
		start, 
		end + (20 * dir), 
		(20 * dir)
	):
		
		if can_spawn == true:
			yield(get_tree().create_timer(0.1), "timeout")
			spawn_firecolumn(Vector2(x, global_position.y))
			yield(get_tree().create_timer(0.05), "timeout")
	
	if dir == 1:
		spawn_active_l = false
	else:
		spawn_active_r = false
	
	is_active = false


func get_position_outside_area(side: int = 1) -> Vector2:
	var result: Vector2
	var camera_pos: Vector2 = VarsGlobal.GameScenario.CameraNode.get_camera_position()
	
	if side == - 1:
		result = PosA.global_position
	else:
		result = PosB.global_position

	result.y = camera_pos.y - 30

	return result

func spawn_firecolumn(fire_pos: Vector2) -> void :
	var ObjInstance = FireColumn.instance()
	ObjInstance.global_position = fire_pos
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
