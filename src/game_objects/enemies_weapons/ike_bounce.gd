extends KinematicBody2D

var Particle = preload("res://src/game_objects/vfx/shine_particle.tscn")

signal destroyed_by_player

var speed: float = 250
var extra_speed: float = 1

var angle_degrees: float = 45
var velocity: Vector2

var random_degrees: bool

var dir_play: int = 1

onready var CoolDown = $CoolDown

func _ready():
	$ShineParticle.emitting = true
	Audio.play_sfx("shoot_projectile_light")
	Audio.play_sfx("skull_invocation")
	
	if random_degrees == true:
		randomize()
		angle_degrees = rand_range(0, 360)
	
	var angle_radians = deg2rad(angle_degrees)
	
	velocity = Vector2(cos(angle_radians), sin(angle_radians)) * speed

	if dir_play == 1:
		$AnimationPlayer.play("spin")
	else:
		$AnimationPlayer.play_backwards("spin")

func _physics_process(delta):
	var reflected: bool
	var collision = move_and_collide(velocity * delta * extra_speed, false)
	if collision != null and reflected == false and CoolDown.is_stopped():
		CoolDown.start(0.1)
		snd_collision()
		reflected = true
		
		var normal = collision.normal
		
		
		
		velocity = velocity - (2 * (velocity.dot(normal)) * normal)
		
		instance_particle(collision.position)
		

func instance_particle(pos: Vector2 = global_position) -> void :
	var ObjInstance = Particle.instance()
	ObjInstance.global_position = pos
	ObjInstance.amount = 10
	ObjInstance.z_index = 2
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func increase_extra_speed() -> void :
	if CoolDown.is_stopped() and extra_speed < 2.0:
		CoolDown.start(0.5)
		extra_speed += 0.1

func snd_collision() -> void :
	Audio.play_sfx("impact_shield_clang")

func _on_HurtboxEnemySimple_damaged() -> void :
	instance_particle()
	snd_collision()
	
	var pos: Vector2 = global_position
	var p_pos: Vector2 = VarsGlobal.Player.global_position
	angle_degrees = rad2deg(pos.direction_to(p_pos).angle()) + 180
	var angle_radians = deg2rad(angle_degrees)
	velocity = Vector2(cos(angle_radians), sin(angle_radians)) * speed

func _on_HurtboxEnemySimple_defeated() -> void :
	$ShineParticle.emitting = true
	emit_signal("destroyed_by_player")
	set_physics_process(false)
	$AnimationPlayer.play("destroyed")

func _on_TimerActive_timeout() -> void :
	_on_HurtboxEnemySimple_defeated()
