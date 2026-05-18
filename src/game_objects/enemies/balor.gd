extends KinematicBody2D

var FireballBalor = preload("res://src/game_objects/enemies_weapons/fireball_balor.tscn")

export (String, "up_down", "flying") var pattern = "up_down"

var distance: float = 80.0
var speed: float = 50.0

var velocity: Vector2

var initial_position: Vector2

var dir_x: int = 0

var dir_y: int = 1

onready var Enemy = $EnemyBase
onready var TimerMove = $TimerMove

func _ready() -> void :
	
	if pattern == "up_down":
		Enemy.change_state("idle", true)
		
	if pattern == "flying":
		Enemy.change_state("flying")
		$HurtboxEnemy.hp_now = int($HurtboxEnemy.hp_now / 2)
		$HurtboxEnemy.hp_max = $HurtboxEnemy.hp_now
	
	TimerMove.wait_time = distance / speed
	TimerMove.start()
	start_tween()
	
	
	
func _process(_delta: float) -> void :
	if Enemy.state == "flying":
		velocity.x = (speed * 2) * dir_x
	velocity = move_and_slide(
		velocity, Vector2.UP
	)

func start_tween() -> void :

	
	dir_y *= - 1
	initial_position = position
	
	var target_position = initial_position.y + (distance * dir_y)
	
	$Tween.interpolate_property(
		self, "position:y", initial_position.y, target_position, 
		TimerMove.wait_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	$Tween.start()

func _spawn_fireball() -> void :
	Audio.play_sfx("shoot_projectile")
	var ObjInstance = FireballBalor.instance()
	ObjInstance.global_position = $Sprite / PositionFireball.global_position
	ObjInstance.dir = Enemy.facing
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	

func _on_before_fireball() -> void :
	Audio.play_sfx("spell_prepare")
	$TimerMove.set_paused(true)
	$Tween.set_active(false)
func _on_after_fireball() -> void :
	Enemy.change_direction("to_player")
	Enemy.change_state("idle")
	$TimerMove.set_paused(false)
	$Tween.resume_all()
	randomize()
	$TimerFireball.start(rand_range(2, 3.5))

func _on_TimerMove_timeout() -> void :
	if Enemy.state in ["dead"]:
		return
	
	if Enemy.state != "fireball":
		start_tween()
	
	if Enemy.state == "idle":
		Enemy.change_direction("to_player")

func _on_TimerFireball_timeout() -> void :
	if Enemy.state in ["flying", "dead"]:
		return

	if Enemy.state == "idle" and $VisibilityNotifierCameraArea.is_on_screen():
		Enemy.change_state("fireball")
	else:
		$TimerFireball.start(0.5)

func _on_HurtboxEnemy_defeated() -> void :
	$Tween.stop_all()

func _on_VisibilityNotifier2D_screen_exited() -> void :
	if pattern == "flying":
		queue_free()
