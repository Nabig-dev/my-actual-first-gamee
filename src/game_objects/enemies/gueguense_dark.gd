extends KinematicBody2D


var velocity: = Vector2()

var gravity: int = 350

var speed: int = 50

onready var Enemy = $EnemyBase
onready var TimerDash = $TimerDash
onready var TimerPatrol = $TimerPatrol
onready var Area2DCastPlayerInRange = $Area2DCastPlayerInRange
onready var Area2DCastPlayerFly = $Sprite / Area2DCastPlayerFly
onready var RayCast2DEnemyFront = $Sprite / RayCast2DEnemyFront
onready var Area2DCastNoFloor = $Sprite / Area2DCastNoFloor

onready var CollisionStand = $HitboxEnemy / CollisionStand
onready var CollisionFly = $HitboxEnemy / CollisionFly

onready var GhostTrail = $GhostTrail

func _ready() -> void :
	Enemy.change_state("idle", true)


func _physics_process(delta) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing

	if is_on_floor() and (
		Enemy.state in ["idle", "dead"]
	):
		velocity.x = 0

	if Enemy.state != "fly":
		velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if is_on_wall() and Enemy.state != "fly":
		if Enemy.state == "walk":
			Enemy.change_state("idle")
			Enemy.change_direction("inverse")
		elif Enemy.state == "fly":
			Enemy.change_state("walk")
			Enemy.change_direction("inverse")

func _dash() -> void :
	yield(get_tree(), "idle_frame")
	velocity.x = 100 * Enemy.facing
	TimerDash.start(0.2)
	yield(TimerDash, "timeout")
	velocity.x = 0

func _move() -> void :
	velocity.x = (speed * 6) * Enemy.facing
func _stop() -> void :
	velocity.x = 0

func _on_TimerCheckPlayerDir_timeout() -> void :
	if Enemy.state in ["idle", "walk", "pre_fly"]:
		Enemy.change_direction("to_player")


func _on_TimerPatrol_timeout() -> void :
	
	if (
		$Sprite / Area2DCastNoFloor.is_colliding() == false
		and Enemy.state == "idle"
	):
		Enemy.change_direction(str(Enemy.facing * - 1))
		Enemy.change_state("walk")
	
	randomize()
	TimerPatrol.start(randi() % 5 + 1)
	
	if Enemy.state in ["pre_fly", "fly"]:
		return


	if Enemy.state in ["idle", "walk"] and Area2DCastPlayerInRange.is_colliding():
		Enemy.change_direction("to_player")
		Enemy.change_state("attack")
		velocity.x = 0
	
	elif Enemy.state in ["idle"] and Area2DCastNoFloor.is_colliding() == true:
		Enemy.change_state("walk")
	
	elif Enemy.state in ["idle", "walk"] and Area2DCastPlayerFly.is_colliding():
		if RayCast2DEnemyFront.is_colliding() == false and Area2DCastNoFloor.is_colliding() == true:
			Enemy.change_direction("to_player")
			Enemy.change_state("pre_fly")
			velocity.x = 0
		else:
			Enemy.change_direction("inverse")
			Enemy.change_state("walk")
	
	elif Enemy.state in ["walk"]:
		Enemy.change_state("idle")
	




func _on_Area2DCastPlayerInRange_object_entered(_Obj) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_state("attack")
		velocity.x = 0


func _on_Area2DCastPlayerFly_object_entered(_Obj) -> void :
	if Enemy.state in ["idle", "walk"]:
		Enemy.change_direction("to_player")
		Enemy.change_state("pre_fly")
		velocity.x = 0


func _on_Area2DCastNoFloor_object_exited(_Obj) -> void :



	pass


func _on_EnemyBase_state_changed(state) -> void :
	CollisionStand.set_deferred("disabled", true)
	CollisionFly.set_deferred("disabled", true)
	if state != "fly":
		CollisionStand.set_deferred("disabled", false)
	else:
		GhostTrail.stop_trail()
		CollisionFly.set_deferred("disabled", false)

	if state != "attack":
		$Sprite / HitboxEnemy / CollisionShape2DWeapon.set_deferred("disabled", true)


func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["idle"] and Enemy.state != "fly":
		Enemy.change_state("pre_fly")
