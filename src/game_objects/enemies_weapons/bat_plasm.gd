extends KinematicBody2D

var Explosion = preload("res://src/game_objects/enemies_weapons/explosion_molotov.tscn")

var speed: float = 220
var extra_speed: float = 1
var velocity: Vector2

func _ready():
	Audio.play_sfx("shoot_projectile_light")
	$AnimationPlayer.play("show")

	
	var angle_radians = get_angle_to(VarsGlobal.Player.global_position - Vector2(0, 30))
	
	velocity = Vector2(cos(angle_radians), sin(angle_radians)) * speed

func _physics_process(delta: float):
	var collision = move_and_collide(velocity * delta * extra_speed, false)
	if collision != null:
		destroy()
		
func destroy() -> void :
	set_physics_process(false)
	var ObjInstance = Explosion.instance()
	ObjInstance.global_position = global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	queue_free()

func _on_VisibilityNotifier2D_screen_exited() -> void :
	destroy()
