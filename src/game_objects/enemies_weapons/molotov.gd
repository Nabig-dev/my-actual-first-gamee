extends KinematicBody2D

var Explosion = preload("res://src/game_objects/enemies_weapons/explosion_molotov.tscn")

var direction: int = - 1
var gravity: float = 400
var velocity: = Vector2.ZERO
var target_position: = Vector2.ZERO

onready var Spr = $Sprite
onready var AnimP = $AnimationPlayer

var _explosion_make_dmg: bool = true

var _falling: bool = false

func _ready() -> void :
	
	if direction == 1:
		AnimP.play("spin")
	else:
		AnimP.play_backwards("spin")
	
	Spr.scale.x = direction
	

	
	
	
	target_position += Vector2(
		rand_range( - 16, 16), 
		0
	)
	
	var arc_height = target_position.y - global_position.y - 64
	
	arc_height = min(arc_height, - 64)
	
	velocity = PhysicsHelper.calculate_arc_vel(
		global_position, target_position, arc_height, gravity
	)
	velocity = velocity.limit_length(230)
	
	
func _physics_process(delta: float) -> void :
	
	
	if _falling == false and velocity.y > 80:
		_falling = true
		set_collision_mask_bit(0, true)
		set_collision_mask_bit(2, true)
	
	velocity.y += gravity * delta
	
	var collision = move_and_collide(velocity * delta)
	
	if collision != null:
		explode(true)

func explode(instance_fire: bool = false) -> void :
	Audio.play_sfx("impact_bottle_break")
	set_physics_process(false)
	
	var ObjInstance = Explosion.instance()
	ObjInstance.fire_instance = instance_fire
	ObjInstance.global_position = global_position
	ObjInstance.makedmg = _explosion_make_dmg
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
	if instance_fire == true:
		Gamepad.start_vibration(0, 0.3, 0.0, 0.3)
		VarsGlobal.GameScenario.CameraNode.start_shake(
			0.4, false, false
		)
	queue_free()

func _on_HurtboxEnemySimple_defeated() -> void :
	if VarsGlobal.game_data["difficulty_base"] == 0:
		_explosion_make_dmg = false
	explode()

func _on_Area2DDetectPlayer_area_entered(_area: Area2D) -> void :
	explode()
