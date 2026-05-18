extends KinematicBody2D

var velocity: = Vector2()

var gravity: int = 350

var speed: int = 260

onready var Enemy = $EnemyBase
onready var VisibleNotif = $VisibilityNotifierCameraArea
onready var AreaDetectPlayer = $Sprite / AreaDetectPlayer
onready var TimerStartRun = $TimerStartRun
onready var TimerAfterJump = $TimerAfterJump
onready var DetectNoFloor = $Sprite / DetectNoFloor
onready var DetectRampFront = $Sprite / DetectRampFront

var _running: bool

func _ready() -> void :
	Enemy.change_state("idle", true)

func _physics_process(delta) -> void :
	
	if _running == true:
		if is_on_floor():
			velocity.x = speed * Enemy.facing
		else:
			velocity.x = (speed / 1.5) * Enemy.facing
		if DetectRampFront.is_colliding():
			velocity.x = velocity.x / 2

	if Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if is_on_floor() and Enemy.state == "jump" and DetectNoFloor.is_colliding():
		_running = true
		Enemy.change_state("run")
	
	if is_on_wall() == true:
		Enemy.change_direction("inverse")

func jump() -> void :
	if Enemy.state == "dead":
		return
	_running = true
	TimerAfterJump.start()
	velocity.y = - 120

func start_run() -> void :
	if _running == false and TimerStartRun.is_stopped():
		$GhostTrail.start_trail(0.0, 0.1)
		TimerStartRun.start(0.7)
		yield(TimerStartRun, "timeout")
		if Enemy.state != "dead":
			Audio.play_sfx("roar_hound")
			_running = true
			Enemy.change_state("run")
		else:
			$GhostTrail.stop_trail()

func _on_VisibilityNotifierCameraArea_screen_entered() -> void :
	if Enemy.state == "dead":
		return
	if is_on_floor():
		Enemy.change_direction("to_player")
	if AreaDetectPlayer.is_colliding() == true:
		start_run()

func _on_AreaDetectPlayer_object_entered(_Obj) -> void :
	if Enemy.state == "dead":
		return
	if VisibleNotif.is_on_screen() == false:
		return
	start_run()

func _on_VisibilityNotifierCameraArea_screen_exited() -> void :
	if Enemy.state != "dead" and _running == true and is_on_floor():
		Enemy.change_direction("to_player")

func _on_DetectNoFloor_object_exited(_Obj) -> void :
	if Enemy.state != "dead" and _running == true:
		_running = false
		velocity.x = 0
		Enemy.change_state("jump")

func _on_DetectNoFloor_object_entered(_Obj) -> void :
	if _running == false and Enemy.state == "jump":
		_running = true
		Enemy.change_state("run")

func _on_HurtboxEnemy_defeated() -> void :
	$GhostTrail.stop_trail()
