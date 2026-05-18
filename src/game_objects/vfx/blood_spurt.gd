extends KinematicBody2D

var dir: int = 1
var velocity: Vector2
var gravity: float = 15
var speed: float = 80
var jump_impulse: float = 3
var rotation_speed: float = 0.1

var _active: bool = true

func _ready() -> void :
	randomize()
	
	
	$Sprite.frame = RNGTools.pick([0, 1])
	dir = RNGTools.pick([1, - 1])
	gravity += rand_range( - 5, 5)
	speed += rand_range( - 10, 10)
	jump_impulse += rand_range( - 2, 2)
	
	$Sprite.scale.x = dir
	velocity.y -= jump_impulse

func _physics_process(delta: float) -> void :
	
	if _active == true:
		velocity.x = (speed * dir) * delta
		
		var target_rotation = lerp_angle($Sprite.rotation, dir * sign(velocity.y) * PI / 2, rotation_speed)
		$Sprite.rotation = target_rotation
	
	velocity.y += gravity * delta
	
	var KinemaCol = move_and_collide(velocity)
	
	if KinemaCol != null and _active == true:
		$TimerDisablePhysics.start(3)
		_active = false
		$Sprite.rotation = 0
		$Sprite.frame = RNGTools.pick([2, 3, 4])
		$Sprite.scale.x = RNGTools.pick([1, - 1])

func _on_VisibilityNotifier2D_screen_exited() -> void :
	if _active == true:
		queue_free()

func _on_TimerDisablePhysics_timeout() -> void :
	set_physics_process(false)
	var Tw: = create_tween().tween_property(
		$Sprite, "modulate", Color("878787"), 5
	)
	Tw.connect("finished", self, "_on_tween_1_end")

func _on_tween_1_end() -> void :
	var Tw: = create_tween().tween_property(
		$Sprite, "modulate", Color("00878787"), 3
	)
	Tw.connect("finished", self, "_on_tween_2_end")

func _on_tween_2_end() -> void :
	queue_free()

