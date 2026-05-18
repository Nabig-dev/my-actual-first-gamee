extends KinematicBody2D

var Shoot = preload("res://src/game_objects/enemies_weapons/eyebullet_bullet.tscn")

export var move: bool = true

var distance: float = 80.0
var speed: float = 50.0

var velocity: Vector2

var initial_position: Vector2

var dir_y: int = 1

onready var Enemy = $EnemyBase
onready var TimerMove = $TimerMove
onready var AnimShoot = $AnimShoot
onready var AreaSeePlayer = $Eyebulet / AreaSeePlayer
onready var VisibleNotif = $VisibilityNotifierCameraArea

func _ready() -> void :
	Enemy.change_state("idle", true)
	
	TimerMove.wait_time = distance / speed
	TimerMove.start()
	start_tween()
	
	
	if move == false:
		Enemy.change_direction("1")

func start_tween() -> void :

	if move == false:
		return

	
	dir_y *= - 1
	initial_position = position
	
	var target_position = initial_position.y + (distance * dir_y)
	
	$Tween.interpolate_property(
		self, "position:y", initial_position.y, target_position, 
		TimerMove.wait_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	$Tween.start()

func start_shoot() -> void :
	if VisibleNotif.is_on_screen() == true:
		Audio.play_sfx("spell_prepare3")
		AnimShoot.play("shoot")

func _spawn_shoot() -> void :
	if Enemy.state == "dead":
		return
	var ObjInstance = Shoot.instance()
	ObjInstance.dir = Enemy.facing
	ObjInstance.global_position = $Eyebulet / PositionShoot.global_position
	ObjInstance.target_position = $Eyebulet / PositionTarget.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _on_after_shoot() -> void :
	if AreaSeePlayer.is_colliding() == true and Enemy.state != "dead":
		start_shoot()

func _on_TimerMove_timeout() -> void :
	if Enemy.state in ["dead"]:
		return
	
	start_tween()
	
	if Enemy.state == "idle" and rotation_degrees == 0:
		Enemy.change_direction("to_player")

func _on_HurtboxEnemy_defeated() -> void :
	$Tween.stop_all()

func _on_AreaSeePlayer_object_entered(_Obj) -> void :
	if AnimShoot.is_playing() == false:
		start_shoot()
