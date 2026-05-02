extends KinematicBody2D

var distance: float = 60.0
var speed: float = 80

var velocity: Vector2

var initial_position: Vector2

var dir_x: int = 0


var dir_y: int = 1


onready var TimerMove = $TimerMove
onready var Enemy = $EnemyBase

func _ready() -> void :

	Enemy.change_state("fly")
	
	TimerMove.wait_time = distance / speed
	TimerMove.start()

	if dir_x == 0:
		dir_x = Enemy.facing * - 1
	
	start_tween()
	
func _physics_process(_delta: float) -> void :
	
	if Enemy.state == "fly":
		velocity.x = 100 * dir_x
	
	if Enemy.state == "dead":
		velocity.y = 300
	
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

func _on_TimerMove_timeout() -> void :
	start_tween()


func _on_HurtboxEnemy_defeated() -> void :
	velocity.x = 0
	TimerMove.stop()
	$Tween.stop_all()


func _on_VisibilityNotifier2D_screen_exited() -> void :
	if Enemy.state in ["fly", "dead"]:
		queue_free()


func _on_VisibilityNotifier2D_screen_entered() -> void :
	var max_speed: float = speed
	var Tw: = create_tween()
	speed = 0
	velocity.x = 0
	
	Tw.tween_property(self, "speed", max_speed, 1)
