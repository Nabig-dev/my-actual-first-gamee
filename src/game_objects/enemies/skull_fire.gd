extends KinematicBody2D



var Fireball = preload("res://src/game_objects/enemies_weapons/fireball.tscn")


var velocity: = Vector2()

var gravity: int = 300


var _firewalls_throws: int = 0

onready var Enemy = $EnemyBase
onready var AreaSeePlayer = $Sprite / AreaSeePlayer
onready var VisibNotif = $VisibilityNotifierCameraArea
onready var TimerDelayAtk = $TimerDelayAtk
onready var ParticlesFire = $Sprite / ParticlesFire

func _physics_process(delta) -> void :

	if Enemy.state == "dead":
		velocity.y = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	
	
	
	






func start_attack() -> void :
	ParticlesFire.emitting = false
	
	randomize()
	TimerDelayAtk.start(rand_range(1.5, 2.5))
	yield(TimerDelayAtk, "timeout")
	
	var new_atk: String = RNGTools.pick(["fireball", "fire"])
	if new_atk == "fireball":
		_firewalls_throws = 0
		Enemy.change_state("fireball")

	else:
		Enemy.change_state(new_atk)

func spawn_fireball() -> void :
	_firewalls_throws += 1
	var ObjInstance = Fireball.instance()
	ObjInstance.dir = Enemy.facing
	if AreaSeePlayer.is_colliding() == false:
		ObjInstance.gravity_enabled = true
	ObjInstance.global_position = $Sprite / PositionFireball.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	

func repeat_fireball() -> void :
	
	if Enemy.state == "dead":
		return
		
	randomize()
	_firewalls_throws += RNGTools.pick([0, 0, 1, 2])
	
	if _firewalls_throws > 4:
		_firewalls_throws = 0
		Enemy.change_state("idle")
	else:
		Enemy.change_state("spawn", true)


func _on_AreaSeePlayer_object_entered(_Obj) -> void :
	if Enemy.state == "idle":
		Enemy.change_direction("to_player")
		start_attack()


func _on_EnemyBase_state_changed(state: String) -> void :
	
	if state == "dead":
		return
	
	if AreaSeePlayer.is_colliding() == false and Enemy.state == "idle":
		randomize()
		Enemy.change_direction(RNGTools.pick(["1", "-1"]))
	elif Enemy.state == "idle":
		Enemy.change_direction("to_player")

	if (
		state == "idle"
		and VisibNotif.is_on_screen()
		and Enemy.state != "spawn"
	):
		start_attack()

func _on_VisibilityNotifierCameraArea_screen_entered() -> void :
	if Enemy.state == "idle":
		start_attack()
