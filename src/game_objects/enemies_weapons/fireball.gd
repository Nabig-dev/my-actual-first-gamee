extends KinematicBody2D

var dir: int = 1
var gravity_enabled: bool = false

var velocity: Vector2
var speed: float = 250
var gravity: int = 200

func _ready() -> void :
	$Fireball.scale.x = dir
	Audio.play_sfx("shoot_projectile")
	$AnimationPlayer.play("fly")
	
	if gravity_enabled == true:
		
		velocity.y = - 80
		speed = speed / 2
		
		var Tw: = get_tree().create_tween()
		
		Tw.tween_property(
			$Fireball, "rotation_degrees", 50 * dir, 2
		)
	
func _physics_process(delta: float) -> void :
	velocity.x = speed * dir
	if gravity_enabled == true:
		velocity.y += gravity * delta
	velocity = move_and_slide(velocity)

func _on_HurtboxEnemy_defeated() -> void :
	set_physics_process(false)
	$AnimationPlayer.play("dead")
	velocity = Vector2.ZERO
	speed = 0

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
