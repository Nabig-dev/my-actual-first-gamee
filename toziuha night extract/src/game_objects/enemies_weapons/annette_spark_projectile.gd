extends KinematicBody2D

var dir: int = 1
var velocity: Vector2
var speed: float = 340

func _ready() -> void :
	Audio.play_sfx("shoot_projectile_light")
	Audio.play_sfx("sword_slash_slow4")
	Audio.play_sfx("sword_slash_slow4")
	$AnimationPlayer.play("show")
	$Sprite.scale.x = dir

func _physics_process(_delta: float) -> void :
	velocity.x = speed * dir
	velocity = move_and_slide(velocity)
