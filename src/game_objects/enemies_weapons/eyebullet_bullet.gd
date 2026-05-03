extends KinematicBody2D

var dir: int = 1

var target_position: Vector2
var speed: float = 400.0

var velocity: Vector2

func _ready() -> void :
	
	
	
	Audio.play_sfx("shoot_projectile_juicy")
	Audio.play_sfx("shoot_projectile_light")
	
	velocity = position.direction_to(target_position).normalized() * speed
	look_at_target()

func _physics_process(delta: float):
	
	move_and_collide(velocity * delta)

func look_at_target():
	var direction_to_target = target_position - $Sprite.global_position
	var angle_to_target = direction_to_target.angle()
	
	$Sprite.set_rotation(angle_to_target)

func _on_HurtboxEnemy_defeated() -> void :
	queue_free()

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
