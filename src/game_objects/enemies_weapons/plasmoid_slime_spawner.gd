extends RigidBody2D

var Slime = preload("res://src/game_objects/enemies/slime.tscn")

func kick(kick_dir: int):
	randomize()
	
	var kick_force: float = rand_range(200.0, 300.0)
	
	
	var kick_direction = Vector2(kick_dir, 0).rotated(
		deg2rad(
			rand_range(60 * (kick_dir * - 1), 120 * (kick_dir * - 1))
		)
	)

	var kick_vector = kick_direction.normalized() * kick_force
	
	apply_central_impulse(kick_vector)


func _on_PlasmoidSlimeSpawner_body_shape_entered(_body_rid: RID, _body: Node, _body_shape_index: int, _local_shape_index: int) -> void :
	$TimerSpawn.start()


func _on_TimerSpawn_timeout() -> void :
	var ObjInstance = Slime.instance()
	ObjInstance.global_position = global_position
	ObjInstance.add_to_group("slime_spawned")
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	queue_free()
