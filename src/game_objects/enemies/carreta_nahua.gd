extends KinematicBody2D

var Parcae = preload("res://src/game_objects/enemies/parcae.tscn")

export var limit_l_position: NodePath
export var limit_r_position: NodePath

var speed: int = 80
var velocity: = Vector2()
var gravity: = 350

var _limit_l: Vector2
var _limit_r: Vector2


onready var Spr = $Sprite
onready var Enemy = $EnemyBase



func _ready() -> void :
	
	if (
		get_node_or_null(limit_l_position) != null
		and get_node_or_null(limit_r_position) != null
	):
		_limit_l = get_node(limit_l_position).global_position
		_limit_r = get_node(limit_r_position).global_position
	
	
	
	
	Enemy.change_state("walk", true)

func change_dir() -> void :
	Enemy.change_direction("inverse")
	

func _physics_process(delta: float) -> void :
	
	if Enemy.state == "walk":
	
		velocity.x = speed * Enemy.facing
		
		if (
			(Enemy.facing == - 1 and global_position.x <= _limit_l.x)
			or (Enemy.facing == 1 and global_position.x >= _limit_r.x)
			or is_on_wall() == true
			and Enemy.state != "changedir"
			
		):
			
			velocity.x = 0
			Enemy.change_state("changedir", true)

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)

func _set_velocity_x(vel: float) -> void :
	velocity.x = vel


func _on_EnemyBase_enemy_defeated(_NodeEnemy) -> void :
	_on_CarretaNahua_tree_exiting()
	var ObjInstance = Parcae.instance()
	ObjInstance.global_position = $Sprite / Position2DParca.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	


func _on_CarretaNahua_tree_exiting() -> void :
	velocity.x = 0
	$AudioStreamPlayer2D.stop()
	$Whisper.stop()
