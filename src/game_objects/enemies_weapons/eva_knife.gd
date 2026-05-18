extends RigidBody2D

var dir: int = 1

onready var Hitbox = $HitboxEnemy
onready var Spr = $Sprite
onready var TweenRotate = $TweenRotate

func _ready() -> void :
	Spr.scale.x = dir
	apply_impulse(Vector2(0, 0), Vector2(370 * dir, 0))

func _weapon_impact() -> void :
	Hitbox.set_deferred("monitoring", false)
	Hitbox.set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)
	Audio.play_sfx("impact_shuriken")
	VarsGlobal.GameScenario.show_hit_lines(
		"hit_low", 1, global_position
	)
	linear_velocity = Vector2.ZERO
	gravity_scale = 9
	apply_impulse(
		Vector2.ZERO, 
		Vector2(
			RNGTools.randi_range( - 100, - 25) * dir, 
			RNGTools.randi_range( - 30, - 15)
		)
	)
	
	TweenRotate.interpolate_property(
		Spr, "rotation_degrees", 
		0, - 360 * dir, 0.5
	)
	TweenRotate.start()


func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()


func _on_RigidBody2D_body_shape_entered(_body_rid: RID, _body: Node, _body_shape_index: int, _local_shape_index: int) -> void :
	_weapon_impact()

func _on_HurtboxEnemySimple_defeated() -> void :
	_weapon_impact()
