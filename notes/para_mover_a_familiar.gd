extends KinematicBody2D





var chasing: bool

onready var Tw = $Tween
onready var Enemy = $EnemyBase

func _ready() -> void :
	Enemy.change_state("appear")
	yield(Enemy, "state_changed")
	$TimerChase.start(1)

func start_chase() -> void :
	
	if Enemy.state in ["appear", "dead"]:
		return

	Tw.remove_all()
	Tw.stop_all()

	var chase_duration = 2
	
	Enemy.change_direction("to_player")
	chasing = true
	Tw.interpolate_property(
		self, 
		"global_position", 
		global_position, 
		Enemy.get_player_position(Vector2(0, - 32)), 
		chase_duration, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	Tw.start()


func _on_TimerChase_timeout() -> void :
	start_chase()
