extends KinematicBody2D

var direction: int = - 1
var gravity: float = 350
var velocity: = Vector2.ZERO
var target_position: = Vector2.ZERO

var _last_weapon_pos: Vector2

onready var AnimP = $AnimationPlayer

func _ready() -> void :
	if direction == 1:
		AnimP.play("spin")
	else:
		AnimP.play_backwards("spin")
	

	
	var arc_height = target_position.y - global_position.y - 64
	
	arc_height = min(arc_height, - 64)
	
	velocity = PhysicsHelper.calculate_arc_vel(
		global_position, target_position, arc_height, gravity
	)
	velocity = velocity.limit_length(250)

func _physics_process(delta: float) -> void :
	velocity.y += gravity * delta
	
	move_and_collide(velocity * delta)
	

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()

func _on_HurtboxEnemy_defeated() -> void :
	
	modulate = Color("3e515151")
	
	var new_vel: Vector2 = velocity
	
	if global_position.x < _last_weapon_pos.x:
		
		new_vel.x = abs(new_vel.x) * - 1
	else:
		
		new_vel.x = abs(new_vel.x)
	
	new_vel.y = abs(new_vel.y) * - 1

	velocity = new_vel

func _on_HurtboxEnemySimple_area_entered(area: Area2D) -> void :
	_last_weapon_pos = area.global_position
