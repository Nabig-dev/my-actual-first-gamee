extends KinematicBody2D

var velocity: = Vector2()

var gravity: int = 350

var speed: int = 150

onready var Enemy = $EnemyBase

func _ready() -> void :
	Audio.play_sfx("shoot_projectile")
	Enemy.change_state("falling", true)
	
func _physics_process(delta) -> void :
	
	if Enemy.state == "run":
		velocity.x = speed * Enemy.facing

	if Enemy.state in ["idle", "dead"]:
		velocity.x = 0

	velocity.y += gravity * delta

	velocity = move_and_slide(velocity, Vector2.UP, true)
	
	if is_on_floor() and Enemy.state == "run" and is_on_wall():
		Enemy.change_direction("inverse")

	if is_on_floor() == true and Enemy.state == "falling":
		Enemy.change_state("run")
		$GhostTrail.start_trail(0, 0.1)
