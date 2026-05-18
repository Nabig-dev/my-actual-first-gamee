extends KinematicBody2D

var speed: int = 30
var velocity: = Vector2()
var gravity: = 350

onready var Enemy = $EnemyBase
onready var RayCastFloorFront = $Sprite / RayCastFloorFront
onready var AreaSeePlayer = $Sprite / AreaSeePlayer

func _ready() -> void :
	Enemy.change_state("walk", true)

func _physics_process(delta: float) -> void :
	
	if Enemy.state == "walk":
		velocity.x = speed * Enemy.facing
	
	if (
		RayCastFloorFront.is_colliding() == false
		or is_on_wall()
		and Enemy.state in ["walk", "idle"]
	):
		Enemy.change_direction("inverse")

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)

func set_dash(vel_x: float = 0) -> void :
	velocity.x = Enemy.facing * vel_x

func snd_knife() -> void :
	Audio.play_sfx("sword_slash_light")

func snd_whistle() -> void :
	Audio.play_sfx("cegua_whistle")

func _on_EnemyBase_enemy_defeated(_NodeEnemy) -> void :
	velocity.x = 0

func _on_TimerMakeAtk_timeout() -> void :
	if (
		AreaSeePlayer.is_colliding() == true
		and Enemy.state in ["walk", "idle"]
	):
		$Sprite / ParticlesGas.gravity = Vector2(
			50 * Enemy.facing, 20
		)
		velocity.x = 0
		randomize()
		var new_atk: String = RNGTools.pick(
			["gas", "atk_fast", "atk_run"]
		)
		Enemy.change_state(new_atk)

func _on_HurtboxEnemy_damaged() -> void :
	if Enemy.state in ["walk", "idle"]:
		Enemy.change_direction("to_player")

func _on_EnemyBase_state_changed(_state: String) -> void :
	$Sprite / ParticlesGas.emitting = false
	$Sprite / GhostTrail.stop_trail()

func _on_Area2DPlayerNear_area_entered(_area: Area2D) -> void :
	if Enemy.state in ["walk", "idle"]:
		Enemy.change_direction("to_player")
