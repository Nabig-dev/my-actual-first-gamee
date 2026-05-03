extends KinematicBody2D

var dir: int = 1
var speed: float = 500
var velocity: Vector2

var time_active: float = 8

func _ready() -> void :
	Audio.play_sfx("light_flash4")
	speed = 0
	$GasBallBig.scale.x = 1.5 * dir
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")
	
	var Tw: = create_tween()
	
	Tw.tween_property(
		self, "speed", 300, 0.5
	)
	
	$AnimationPlayer.play("loop")
	$TimerActive.start(time_active)
	yield(Tw, "finished")
	var Tw2: = create_tween()
	
	Tw2.tween_property(
		self, "speed", 0, 1
	)

func _physics_process(_delta: float) -> void :
	velocity.x = speed * dir
	velocity = move_and_slide(velocity)

func _on_TimerActive_timeout() -> void :
	$AnimationPlayer.play_backwards("show")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
