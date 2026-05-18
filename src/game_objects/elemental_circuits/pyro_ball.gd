extends RigidBody2D

var dir: int = 1

onready var AnimPlayer = $AnimationPlayer
onready var HitboxWeapon = $EcPyroBall / HitboxWeapon
onready var AreaDetectSolid = $EcPyroBall / AreaDetectSolid
onready var SpriteW = $EcPyroBall

func _ready() -> void :
	
	AnimPlayer.play("idle")
	
	SpriteW.scale.x = dir
	
	apply_impulse(Vector2(0, 0), Vector2(200 * dir, 0))

func _weapon_impact() -> void :
	sleeping = true
	HitboxWeapon.set_deferred("monitoring", false)
	HitboxWeapon.set_deferred("monitorable", false)
	AreaDetectSolid.set_deferred("monitoring", false)
	AnimPlayer.play("explosion")

func _on_VisibilityEnabler2D_screen_exited() -> void :
	queue_free()

func _on_AreaDetectSolid_body_entered(_body: Node) -> void :
	
	
	pass

func _on_HitboxWeapon_area_entered(_area: Area2D) -> void :
	
	pass
