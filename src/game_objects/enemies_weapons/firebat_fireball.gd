extends Node2D

var speed: int = 300

onready var FireballSpr = $Sting

func _ready() -> void :
	Audio.play_sfx("shoot_projectile")
	rotation_degrees = rad2deg(
		global_position.angle_to_point(
			VarsGlobal.Player.global_position - Vector2(0, 30)
		)
	)

func _process(delta: float) -> void :
	speed += 1
	FireballSpr.position.x -= speed * delta

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()


func _on_HurtboxEnemySimple_defeated() -> void :
	queue_free()
