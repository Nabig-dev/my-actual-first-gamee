extends KinematicBody2D

var SkullA = preload("res://src/game_objects/enemies_weapons/skull_padre_sin_cabeza.tscn")

export var limit_l_position: NodePath
export var limit_r_position: NodePath

var speed: int = 40
var velocity: = Vector2()

var _limit_l: Vector2
var _limit_r: Vector2

onready var Enemy = $EnemyBase
onready var VisibilityNotify = $VisibilityNotifierCameraArea

func _ready() -> void :
	
	if (
		get_node_or_null(limit_l_position) != null
		and get_node_or_null(limit_r_position) != null
	):
		_limit_l = get_node(limit_l_position).global_position
		_limit_r = get_node(limit_r_position).global_position
	
	Enemy.change_state("walk", true)
	$AnimationFly.play("fly")

func _physics_process(_delta: float) -> void :
	
	if Enemy.state == "walk":
	
		velocity.x = speed * Enemy.facing
		
		if (
			(Enemy.facing == - 1 and global_position.x <= _limit_l.x)
			or (Enemy.facing == 1 and global_position.x >= _limit_r.x)
		):
			velocity.x = 0
			Enemy.change_direction("inverse")

	velocity = move_and_slide(velocity, Vector2.UP, true)

func spawn_skull_a() -> void :
	if Enemy.state == "dead":
		return
	Audio.play_sfx("skull_invocation")
	var ObjInstance = SkullA.instance()
	ObjInstance.global_position = $Sprite / Position2DHead.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	


func _on_EnemyBase_enemy_defeated(_NodeEnemy) -> void :
	velocity.x = 0
	$AnimationFly.stop(true)
	_on_ElPadreSinCabeza_tree_exiting()


func _on_TimerMakeAtk_timeout() -> void :
	randomize()
	if (
		VisibilityNotify.is_on_screen() == true
		and Enemy.state in ["walk"]
	):
		velocity.x = 0
		Enemy.change_direction("to_player")
		Enemy.change_state("atk_a")
		Audio.play_sfx("signum_crucis")

	$TimerMakeAtk.start(
		rand_range(5, 7)
	)


func _on_ElPadreSinCabeza_tree_exiting() -> void :
	Audio.stop_sfx("signum_crucis")
