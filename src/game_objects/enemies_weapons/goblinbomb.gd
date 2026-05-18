extends KinematicBody2D

var VenomCloud = preload("res://src/game_objects/enemies_weapons/venom_cloud.tscn")

var direction: int = - 1
var gravity: float = 350
var velocity: = Vector2.ZERO
var target_position: = Vector2.ZERO

var _spawn_venom_cloud: bool = false

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
	

func _spawn_venom() -> void :
	if _spawn_venom_cloud == true:
		var dir_atk: int = 0
		var ObjInstance = VenomCloud.instance()
		ObjInstance.global_position = global_position
		ObjInstance.dir = dir_atk
		VarsGlobal.GameScenario.add_child(ObjInstance)

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()

func _on_HurtboxEnemy_defeated() -> void :
	Audio.play_sfx("explosion_clean")
	set_physics_process(false)
	AnimP.play("explosion")

func _on_AreaDetectSolid_body_entered(body: Node) -> void :
	if body == VarsGlobal.Player:
		_spawn_venom_cloud = false
	else:
		_spawn_venom_cloud = true
	_on_HurtboxEnemy_defeated()
