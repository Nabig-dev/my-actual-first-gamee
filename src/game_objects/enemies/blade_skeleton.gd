extends KinematicBody2D



var Slash = preload("res://src/game_objects/enemies_weapons/aeria_slash.tscn")


var velocity: = Vector2()

var gravity: int = 250

var speed: int = 60

var _patrol: bool = true

onready var Enemy = $EnemyBase
onready var AreaNoFloor = $Sprite / DetectNoFloor
onready var AreaPlayerFront = $Sprite / AreaPlayerFront
onready var PositionSlash = $Sprite / PositionSlash
onready var VisibilityNotifierCameraArea = $VisibilityNotifierCameraArea

func _ready() -> void :
	Enemy.change_state("walk", true)

func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if Enemy.state in ["idle", "dead", "attack"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if (
		(is_on_floor() and Enemy.state == "walk")
		and (is_on_wall() or AreaNoFloor.is_colliding() == false)
	):
		Enemy.change_direction("inverse")

func make_attack() -> void :
	if (
		VisibilityNotifierCameraArea.is_on_screen()
		and Enemy.state != "attack"
	):
		_patrol = false
		Enemy.change_direction("to_player")
		Enemy.change_state("attack")

func return_to_patrol() -> void :
	if AreaPlayerFront.is_colliding() == false:
		_patrol = true
		Enemy.change_state("walk")
	elif (
		VisibilityNotifierCameraArea.is_on_screen()
		and AreaPlayerFront.is_colliding() == true
	):
		Enemy.state = "idle"
		make_attack()
	else:
		_patrol = true
		Enemy.change_state("idle")

func spawn_slash() -> void :
	var ObjInstance = Slash.instance()
	ObjInstance.global_position = PositionSlash.global_position
	ObjInstance.dir = Enemy.facing
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func snd_slash() -> void :
	Audio.play_sfx("sword_slash_slow4")

func _on_TimerChangePatrolState_timeout() -> void :
	
	if (
		AreaPlayerFront.is_colliding() == true
		
	):
		make_attack()
		return
	
	randomize()
	
	if _patrol == true:
		if Enemy.state == "idle":
			Enemy.change_state("walk")
		elif Enemy.state == "walk":
			Enemy.change_direction(
				RNGTools.pick(["1", "-1"])
			)
			Enemy.change_state("idle")
	
	$TimerChangePatrolState.start(
		rand_range(1, 2.5)
	)


func _on_AreaPlayerFront_object_entered(_Obj) -> void :
	if Enemy.state in ["walk", "idle"]:
		make_attack()


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["walk", "idle"]:
		Enemy.change_direction("to_player")
