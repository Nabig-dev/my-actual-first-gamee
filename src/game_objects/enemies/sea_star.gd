extends KinematicBody2D


export var dir: int = 1
export var move_by_rotation: bool = true
export var invert_gravity: bool = false

var velocity: Vector2
var gravity: float = 2000
var speed: float = 30
var snap: float = 16

var floor_dir: Vector2 = Vector2.DOWN
var up_dir: Vector2 = Vector2.UP

var dir_move: Vector2

var _was_on_floor: bool = true

var _initial_rotation_dir: int

onready var Spr = $Seastar
onready var Collision = $CollisionPolygon2D
onready var ChangeVectorsCooldown = $ChangeVectorsCooldown
onready var TimerReady = $TimerReady

func _ready() -> void :
	
	_initial_rotation_dir = dir
	
	if invert_gravity == true:
		_initial_rotation_dir = _initial_rotation_dir * - 1
		_invert_slide_vectors()
	
	if dir == 0:
		set_physics_process(false)
	else:
		dir_move = Vector2(dir, 0)

	var ArmNodes: Array = $Seastar / Arms.get_children()
	ArmNodes.append_array($Seastar / BackArms.get_children())
	
	for nArm in ArmNodes:
		if nArm is Sprite:
			nArm.material = Spr.material

func _bubble_snd() -> void :
	Audio.play_sfx("bubble_a")

func _physics_process(delta: float) -> void :
	
	Spr.rotation_degrees += (speed * _initial_rotation_dir) * delta
	Collision.rotation_degrees += (speed * _initial_rotation_dir) * delta
	
	if move_by_rotation == false:
		return

	_was_on_floor = is_on_floor()

	match dir_move:
		Vector2.RIGHT:
			velocity.x = speed
			velocity.y -= (gravity * up_dir.y) * delta
		Vector2.UP:
			velocity.y = - speed
			velocity.x -= (gravity * up_dir.x) * delta
		Vector2.LEFT:
			velocity.x = - speed
			velocity.y -= (gravity * up_dir.y) * delta
		Vector2.DOWN:
			velocity.y = speed
			velocity.x -= (gravity * up_dir.x) * delta

	velocity = move_and_slide_with_snap(
		velocity, floor_dir * snap, up_dir, true
	)
	
	
	if is_on_wall() == true and ChangeVectorsCooldown.is_stopped():
		ChangeVectorsCooldown.start(0.1)
		
		if dir_move == Vector2.LEFT or dir_move == Vector2.RIGHT:
			dir_move = up_dir
			_invert_slide_vectors()
	
	
	if is_on_floor() and _was_on_floor == false and TimerReady.is_stopped():
		if dir_move == Vector2.UP or dir_move == Vector2.DOWN:
			dir = dir * - 1
			dir_move = Vector2(dir, 0)


func _invert_slide_vectors() -> void :
	
	if floor_dir == Vector2.DOWN:
			floor_dir = Vector2.UP
			up_dir = Vector2.DOWN
	elif floor_dir == Vector2.UP:
			floor_dir = Vector2.DOWN
			up_dir = Vector2.UP

func _on_HurtboxEnemy_defeated() -> void :
	set_physics_process(false)
