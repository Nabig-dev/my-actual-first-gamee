extends RigidBody2D

var dir: int = 1

func _ready() -> void :
	
	$Sprite.scale.x = dir
	
	Audio.play_sfx("shoot_projectile_juicy")
	Audio.play_sfx("shoot_projectile_light")
	
	apply_impulse(
		Vector2.ZERO, 
		Vector2(300 * dir, 0)
	)


func _on_HurtboxEnemy_defeated() -> void :
	queue_free()


func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
