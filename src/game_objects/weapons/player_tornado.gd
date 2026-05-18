extends RigidBody2D

var dir: int = 1

func _ready() -> void :
	
	Audio.play_sfx("woosh_dust")
	
	$AnimationPlayer.play("show")
	
	Audio.play_sfx("woosh_whip_m")
	
	$XandriaTornadoBlades.scale.x = dir

	$HitboxWeapon.scale.x = dir

	apply_impulse(Vector2.ZERO, Vector2(37.5 * dir, 0))

func _on_Tornado_body_entered(_body: Node) -> void :

	pass
