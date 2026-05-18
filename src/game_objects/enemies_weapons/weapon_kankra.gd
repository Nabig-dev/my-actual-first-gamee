extends KinematicBody2D

var Particle = preload("res://src/game_objects/vfx/shine_particle.tscn")

var direction: int = - 1
var gravity: float = 550
var velocity: = Vector2.ZERO
var target_position: = Vector2.ZERO

var speed: float

var _last_weapon_pos: Vector2

var _move_x: bool
var _detect_floor: bool
var _wall_hitted: bool

onready var AnimP = $AnimationPlayer

func _ready() -> void :
	$GhostTrail.start_trail()
	if direction == 1:
		AnimP.play("spin")
	else:
		AnimP.play_backwards("spin")
	
	var arc_height = target_position.y - global_position.y - 96
	
	arc_height = min(arc_height, - 96)
	
	velocity = PhysicsHelper.calculate_arc_vel(
		global_position, target_position, arc_height, gravity
	)
	velocity = velocity.limit_length(350)

func _physics_process(delta: float) -> void :
	if _move_x == false:
		velocity.y += gravity * delta
		
		move_and_collide(velocity * delta)
	else:
		speed += 5
		velocity.x = speed * direction
		velocity = move_and_slide(velocity, Vector2.UP)
		if is_on_wall() and $Timer.is_stopped():
			
			_on_HurtboxEnemy_defeated()
			

func instance_particle(pos: Vector2 = global_position) -> void :
	var ObjInstance = Particle.instance()
	ObjInstance.global_position = pos
	ObjInstance.amount = 10
	ObjInstance.z_index = 2
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func snd_collision() -> void :
	Audio.play_sfx("impact_shield_clang")
	Audio.play_sfx("electric_zap2")

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()

func _on_HurtboxEnemy_defeated() -> void :
	instance_particle()
	snd_collision()
	queue_free()

func _on_HurtboxEnemySimple_area_entered(area: Area2D) -> void :
	_last_weapon_pos = area.global_position
	instance_particle()

func _on_Timer_timeout() -> void :
	_detect_floor = true

func _on_Area2D_body_entered(_body: Node) -> void :
	_move_x = true
	if global_position.x > VarsGlobal.Player.global_position.x:
		direction = - 1
	else:
		direction = 1
	$Weapon / HurtboxEnemySimple.max_hits = 1
	snd_collision()
	instance_particle()

func _on_TimerAutoQueue_timeout() -> void :
	_on_HurtboxEnemy_defeated()
