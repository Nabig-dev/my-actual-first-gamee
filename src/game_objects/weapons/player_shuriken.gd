extends RigidBody2D

var dir: int = 1

onready var HitboxWeapon = $HitboxWeapon
onready var AreaDetectSolid = $AreaDetectSolid
onready var SpriteW = $XandriaSubweapons
onready var GhostTrail = $GhostTrail
onready var Tw = $Tween
onready var Tw2 = $Tween2

func _ready() -> void :
	
	GhostTrail.start_trail(0.5, 0.05)
	
	SpriteW.scale.x = dir
	
	Tw.interpolate_property(
		SpriteW, "rotation_degrees", 
		0, 360 * dir, 1
	)
	Tw.start()
	
	apply_impulse(Vector2(0, 0), Vector2(375 * dir, 0))

func _weapon_impact() -> void :
	HitboxWeapon.set_deferred("monitoring", false)
	HitboxWeapon.set_deferred("monitorable", false)
	AreaDetectSolid.set_deferred("monitoring", false)
	Tw2.interpolate_property(
		SpriteW, "modulate", 
		Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1
	)
	Tw2.start()
	gravity_scale = 9
	apply_impulse(
		Vector2.ZERO, 
		Vector2(
			RNGTools.randi_range( - 400, - 250) * dir, 
			RNGTools.randi_range( - 125, - 50)
		)
	)

func _on_VisibilityEnabler2D_screen_exited() -> void :
	queue_free()

func _on_AreaDetectSolid_body_entered(_body: Node) -> void :
	Audio.play_sfx("impact_shuriken")
	VarsGlobal.GameScenario.show_hit_lines(
		"hit_low", 1, global_position
	)
	_weapon_impact()

func _on_HitboxWeapon_area_entered(_area: Area2D) -> void :
	
	pass
