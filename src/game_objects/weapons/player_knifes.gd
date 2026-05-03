extends RigidBody2D

var dir: int = 1

onready var HitboxWeapon = $HitboxWeapon
onready var AreaDetectSolid = $AreaDetectSolid
onready var SpriteW = $XandriaSubweapons
onready var GhostTrail = $GhostTrail
onready var KnifesParticles2D = $Particles2D
onready var TimerFree = $TimerFree

func _ready() -> void :
	
	ElementalCircuits.apply_mana_cost(
		GVar.EC_MODE.SUBWEAPON, 
		GVar.EC_SUBWEAPON.KNIFES
	)
	
	KnifesParticles2D.visible = false
	
	GhostTrail.start_trail(2, 0.04)
	
	$HitboxWeapon.scale.x = dir
	
	SpriteW.scale.x = dir
	
	apply_impulse(Vector2(0, 0), Vector2(375 * dir, 375))

func _weapon_impact() -> void :
	HitboxWeapon.set_deferred("monitoring", false)
	HitboxWeapon.set_deferred("monitorable", false)
	AreaDetectSolid.set_deferred("monitoring", false)
	SpriteW.visible = false
	KnifesParticles2D.visible = true
	KnifesParticles2D.set_emitting(true)
	GhostTrail.stop_trail()
	linear_velocity = Vector2.ZERO
	TimerFree.start(1.5)

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


func _on_TimerFree_timeout() -> void :
	queue_free()
