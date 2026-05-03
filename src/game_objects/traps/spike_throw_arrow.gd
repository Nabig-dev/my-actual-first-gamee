extends KinematicBody2D

var speed: float = 30000
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void :
	
	if direction == Vector2.RIGHT:
		$Sprite.rotation_degrees = 0
	elif direction == Vector2.LEFT:
		$Sprite.rotation_degrees = - 180
	elif direction == Vector2.UP:
		$Sprite.rotation_degrees = - 90
	elif direction == Vector2.DOWN:
		$Sprite.rotation_degrees = 90

func _physics_process(delta: float) -> void :
	var motion = direction.normalized() * speed * delta
	
	move_and_slide(motion)


func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
