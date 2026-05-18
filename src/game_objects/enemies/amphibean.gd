extends KinematicBody2D

var Fireball = preload("res://src/game_objects/enemies_weapons/firebat_fireball.tscn")
var WaterParticles = preload("res://src/game_objects/vfx/particles_water_splash.tscn")

onready var Enemy = $EnemyBase
onready var Jumpcooldown = $Jumpcooldown
onready var VisibleNotif = $VisibilityNotifier2D

var gravity: float = 280
var velocity: Vector2

var _original_position: Vector2

func _ready() -> void :
	_original_position = global_position
	Enemy.change_state("idle", true)

func _physics_process(delta: float) -> void :
	
	if (
		Enemy.state == "jump"
		and Jumpcooldown.is_stopped()
		and global_position.distance_to(_original_position) < 3
	):
		spawn_splash()
		Audio.play_sfx("water_splash_in2")
		Enemy.change_direction("to_player")
		velocity.y = 0
		Enemy.change_state("idle")
	
	elif Enemy.state == "jump" and global_position < _original_position:
		velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity)

func spawn_splash() -> void :
	var ObjInstance = WaterParticles.instance()
	ObjInstance.global_position = _original_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func jump() -> void :
	if Enemy.state == "jump":
		velocity.y = - 250
		spawn_splash()
		Audio.play_sfx("water_splash_out2")

func spawn_atk() -> void :
	if VisibleNotif.is_on_screen():
		Audio.play_sfx("ec_shoot_fast")
		var ObjInstance = Fireball.instance()
		ObjInstance.speed = 100
		ObjInstance.global_position = $Amphibean / Flare.global_position
		ObjInstance.get_node("Sting/HitboxEnemy").identifier = "amphibean"
		ObjInstance.get_node("Sting/HitboxEnemy").is_weapon = false
		VarsGlobal.GameScenario.add_child(ObjInstance)

func _on_Timer_timeout() -> void :
	if VisibleNotif.is_on_screen() == true and Enemy.state == "idle":
		$TimerAtk.start()
		Jumpcooldown.start(0.6)
		Enemy.change_state("jump")
		$Timer.start(4)
	elif VisibleNotif.is_on_screen() == false:
		$Timer.start(0.5)


func _on_TimerAtk_timeout() -> void :
	$AnimAtk.play("atk")
