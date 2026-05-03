extends KinematicBody2D

var dir: int = 1
var velocity: Vector2
var speed: float = 0
var max_speed: float = 400

func _ready() -> void :
	$Node2D.scale.x = dir
	$AnimationPlayer.play("show")
	Audio.play_sfx("ec_ice_start")

func _physics_process(_delta: float) -> void :
	velocity.x = speed * dir
	velocity = move_and_slide(velocity)

func _on_show_end() -> void :
	var Tw: = create_tween()
	
	Tw.tween_property(
		self, "speed", max_speed, 1.5
	)

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
