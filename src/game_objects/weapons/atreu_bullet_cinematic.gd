extends RigidBody2D

var dir: int = 1

onready var AreaDetectSolid = $AreaDetectSolid
onready var SpriteW = $XandriaSubweapons

func _ready() -> void :
	Audio.play_sfx("atreu_shoot")
	randomize()
	global_position.y += rand_range( - 20, 20)
	SpriteW.scale.x = dir
	SpriteW.self_modulate.a = 0
	
	apply_impulse(Vector2(0, 0), Vector2(400 * dir, 0))

func _weapon_impact() -> void :
	queue_free()

func _on_VisibilityEnabler2D_screen_exited() -> void :
	queue_free()

func _on_AreaDetectSolid_body_entered(_body: Node) -> void :
	
	VarsGlobal.GameScenario.show_hit_lines(
		"hit_low", 1, global_position
	)
	_weapon_impact()

func _on_HitboxWeapon_area_entered(_area: Area2D) -> void :
	
	pass
