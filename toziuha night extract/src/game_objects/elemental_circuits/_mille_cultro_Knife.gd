extends RigidBody2D

var dir: int = 1

onready var SpriteW = $XandriaSubweapons

func _ready() -> void :
	apply_impulse(Vector2(0, 0), Vector2(250 * dir, 0))
	SpriteW.scale.x = dir

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
