extends KinematicBody2D

var Spear = preload("res://src/game_objects/enemies_weapons/axe_boar.tscn")

var velocity: = Vector2()

var gravity: int = 300

var speed: int = 30

onready var Enemy = $EnemyBase
onready var AreaPlayerRange = $Sprite / AreaPlayerRange
onready var Position2DSpear = $Sprite / Position2DSpear
onready var VisibleBody = $VisibleBody

func _ready() -> void :
	Enemy.change_state("idle", true)

func _physics_process(delta) -> void :

	if Enemy.state in ["idle", "throw", "dead"] and is_on_floor():
		velocity.x = 0
	elif Enemy.state == "walk":
		velocity.x = speed * Enemy.facing
	elif Enemy.state == "walk-inverse":
		
		velocity.x = (speed / 2) * (Enemy.facing * - 1)

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if Enemy.state == "walk" and is_on_wall():
		Enemy.change_direction("inverse")
	elif Enemy.state == "walk-inverse" and is_on_wall():
		_on_TimerEndWalkInverse_timeout()

func play_throw_snd() -> void :
	if $VisibilityNotifier2D.is_on_screen() == false:
		return
	Audio.play_sfx("woosh_throw")

func spawn_spear() -> void :
	if (
		VarsGlobal.game_data["player_hp_now"] < 1
		or VisibleBody.is_on_screen() == false
	):
		return
	var SpearInstance = Spear.instance()
	SpearInstance.global_position = Position2DSpear.global_position
	SpearInstance.dir = Enemy.facing

	VarsGlobal.GameScenario.add_child(SpearInstance)

func _on_SpearThrowed() -> void :
	if AreaPlayerRange.is_colliding() and VisibleBody.is_on_screen():
		randomize()
		$TimerEndWalkInverse.start(rand_range(2, 4))
		Enemy.change_state("walk-inverse")
	else:
		Enemy.change_state("walk")

func _on_AreaPlayerRange_object_entered(_Obj) -> void :
	if (
		VisibleBody.is_on_screen() == true
		and Enemy.state in ["idle", "walk", "walk-inverse"]
	):
		Enemy.change_direction("to_player")
		Enemy.change_state("throw")

func _on_VisibilityNotifierCameraArea_screen_entered() -> void :
	if Enemy.state in ["idle", "walk", "walk-inverse"]:
		Enemy.change_direction("to_player")
	if Enemy.state == "idle":
		Enemy.change_state("walk")

func _on_VisibilityNotifierCameraArea_screen_exited() -> void :
	if Enemy.state in ["walk", "walk-inverse"]:
		Enemy.change_state("idle")

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle", "walk", "walk-inverse"]:
		Enemy.change_direction("to_player")

func _on_AreaPlayerRange_object_exited(_Obj) -> void :
	if Enemy.state in ["idle", "walk", "walk-inverse"]:
		Enemy.change_direction("to_player")

func _on_AreaBack_object_entered(_Obj) -> void :
	if Enemy.state in ["idle", "walk", "walk-inverse"]:
		Enemy.change_direction("to_player")

func _on_TimerEndWalkInverse_timeout() -> void :
	if Enemy.state != "walk-inverse":
		return
	Enemy.change_direction("to_player")
	if AreaPlayerRange.is_colliding() and VisibleBody.is_on_screen():
		Enemy.change_state("throw")
	else:
		Enemy.change_state("walk")

func _on_DetectNoFloor_object_exited(_Obj) -> void :
	if is_on_floor() == false:
		return
	if Enemy.state == "walk":
		Enemy.change_direction("inverse")
	elif Enemy.state == "walk-inverse":
		Enemy.change_state("walk")

func _on_EnemyBase_state_changed(state: String) -> void :
	if state == "throw":
		
		Enemy.change_direction("to_player")
