extends StaticBody2D

var Rocks = preload("res://src/game_objects/vfx/rock_particles.tscn")

export var identifier: String
export var max_hits: int = 3

onready var HurtBox = $HurtboxEnemySimple

func _ready() -> void :
	
	if VarsGlobal.has_flag("wall_destroyed_" + identifier) == true:
		queue_free()
		return
	
	var collision: Object = null
	
	for c in get_children():
		
		if (
			c is CollisionShape2D
			or c is CollisionPolygon2D
		):
			collision = c
			collision.disabled = false
	
	HurtBox.add_child(collision.duplicate())
	HurtBox.max_hits = max_hits
	
	

func _on_HurtboxEnemySimple_defeated() -> void :
	if identifier.empty() == false:
		VarsGlobal.add_flag("wall_destroyed_" + identifier)
	var ObjInstance = Rocks.instance()
	ObjInstance.global_position = global_position
	ObjInstance.emitting = true
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	queue_free()
