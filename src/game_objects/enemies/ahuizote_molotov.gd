extends KinematicBody2D

var Molotov = preload("res://src/game_objects/enemies_weapons/molotov.tscn")

var velocity: = Vector2()

var gravity: int = 280

var speed: int = 30

var _inverse_walk: bool = false

onready var Enemy = $EnemyBase
onready var AreaPlayerRange = $Sprite / AreaPlayerRange
onready var Position2DMolotov = $Sprite / Position2DMolotov
onready var TimerPatrolWait = $TimerPatrolWait
onready var TimerRepeatThrow = $TimerRepeatThrow
onready var VisibleEnabler = $VisibilityNotifierCameraArea
onready var TimerCoolDownFirstThrow = $TimerCoolDownFirstThrow

func _ready() -> void :
	start_patrol()

func _physics_process(delta) -> void :

	if Enemy.state == "walk":
		if _inverse_walk == true:
			velocity.x = speed * (Enemy.facing * - 1)
		else:
			velocity.x = (speed * 1.5) * Enemy.facing

	if is_on_floor() and Enemy.state in ["idle", "throw", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)

	
	if is_on_wall() == true and Enemy.state == "walk":
		Enemy.change_direction("inverse")

func return_to_patrol() -> void :
	var distance: float = Enemy.get_player_distance()
	
	if (
		VisibleEnabler.is_on_screen() == true
	):
		if AreaPlayerRange.is_colliding() == true and distance <= 100:
			_inverse_walk = true
		else:
			_inverse_walk = false
		
		Enemy.change_direction("to_player")
		Enemy.change_state("walk")
	
	else:
		start_patrol()

func start_patrol() -> void :
	_inverse_walk = false
	if Enemy.state == "idle":
		Enemy.change_direction("inverse")
		Enemy.change_state("walk")
	else:
		Enemy.change_state("idle")

	randomize()
	TimerPatrolWait.start(rand_range(2, 3))

func start_throw() -> void :
	TimerPatrolWait.stop()
	if (
		AreaPlayerRange.is_colliding() == true
		and TimerCoolDownFirstThrow.is_stopped() == true
	):
		Enemy.change_state("throw")
	else:
		return_to_patrol()

func play_woosh() -> void :
	Audio.play_sfx("woosh_throw")
func spawn_molotov() -> void :
	if (
		VisibleEnabler.is_on_screen() == false
		or VarsGlobal.game_data["player_hp_now"] < 1
	):
		return
	var MolotovInstance = Molotov.instance()
	MolotovInstance.global_position = Position2DMolotov.global_position
	MolotovInstance.direction = Enemy.facing
	MolotovInstance.target_position = Enemy.get_player_position(Vector2(0, - 16))
	VarsGlobal.GameScenario.add_child(MolotovInstance)

func _on_TimerPatrolWait_timeout() -> void :
	start_patrol()

func _on_DetectNoFloor_object_exited(_Obj) -> void :
	if Enemy.state == "walk":
		Enemy.change_direction("inverse")
		velocity.x = 0

func _on_VisibilityNotifierCameraArea_screen_entered() -> void :
	Enemy.change_direction("to_player")
	if Enemy.state in ["walk", "idle"]:
		TimerRepeatThrow.start(1)

func _on_TimerRepeatThrow_timeout() -> void :
	start_throw()
	TimerRepeatThrow.start(1)

func _on_AreaPlayerRange_object_entered(_Obj) -> void :
	start_throw()

func _on_DetectPlayerBack_object_entered(_Obj) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
