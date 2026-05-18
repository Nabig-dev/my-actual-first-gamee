extends RigidBody2D

var dir: int = 1

onready var SpriteW = $XandriaSubweapons
onready var GhostTrail = $GhostTrail
onready var Tw = $Tween

func _ready() -> void :
	

	
	Audio.play_sfx("woosh_whip_m")
	
	GhostTrail.start_trail(1.5, 0.09)
	
	SpriteW.scale.x = dir
	
	Tw.interpolate_property(
		SpriteW, "rotation_degrees", 
		0, 360 * dir, 0.5
	)
	Tw.start()
	
	gravity_scale = 7.5
	
	apply_impulse(Vector2(0, 0), Vector2(100 * dir, - 350))

func _on_VisibilityEnabler2D_screen_exited() -> void :
	if linear_velocity.y > 0:
		queue_free()

func _on_Tween_tween_completed(_object: Object, _key: NodePath) -> void :
	Audio.play_sfx("woosh_whip_m")
