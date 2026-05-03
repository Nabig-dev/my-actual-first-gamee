extends RigidBody2D

var VenomCloud = preload("res://src/game_objects/enemies_weapons/venom_cloud.tscn")


var velocidad = 300
var fuerza_impulso = 150
var dir = - 1

func _ready() -> void :
	$AnimationPlayer.play("collision")
	randomize()
	velocidad = rand_range(200, 400)
	fuerza_impulso = rand_range(100, 250)
	
	var fuerza = Vector2(dir, - 1) * fuerza_impulso
	apply_impulse(Vector2.DOWN, fuerza)

func _destroy() -> void :
	$CPUParticles2D.emitting = true
	$AnimationPlayer.play("nocollision")
	sleeping = true
	$CollisionShape2D.set_deferred("disabled", true)
	$EvaPlasmball.visible = false
	$Area2DDetectPlayer.queue_free()
	$HurtboxEnemySimple.queue_free()
	
	
	var ObjInstance = VenomCloud.instance()
	ObjInstance.dir = 0
	ObjInstance.global_position = global_position
	ObjInstance.add_to_group("atk_eva")
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _on_HurtboxEnemySimple_defeated() -> void :
	_destroy()
func _on_Area2DDetectPlayer_area_entered(_area: Area2D) -> void :
	_destroy()
