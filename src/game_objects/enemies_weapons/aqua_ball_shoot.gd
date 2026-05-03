extends KinematicBody2D

var velocity: Vector2
var speed: int = 200

var target: Vector2

func _ready() -> void :
	randomize()
	var rand_scale: float = rand_range(0.5, 0.8)
	scale = Vector2(rand_scale, rand_scale)
	$AquaBallShootSmall.rotation_degrees = rand_range(0, 360)
	Audio.play_sfx("shoot_projectile_arrow")
	velocity = position.direction_to(target).normalized() * speed
	create_tween().tween_property(self, "speed", 600, 3)

func _physics_process(delta: float) -> void :
	
	var KinemaColl = move_and_collide(velocity * delta)
	
	if KinemaColl != null:
		$AquaBallShootSmall.visible = false
		$FlareCyan.visible = false
		$TimerQueue.start(2)
		$CPUParticles2D.emitting = true
		$HitboxEnemy.queue_free()
		set_physics_process(false)
		Audio.play_sfx("water_splash_move")


func _on_TimerQueue_timeout() -> void :
	queue_free()
