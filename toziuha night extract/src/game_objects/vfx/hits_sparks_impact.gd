extends Node2D

onready var Anim = $AnimationPlayer

func show_hit(
	name_hit: String = "hit1", 
	direction_x: int = 1, glob_position: Vector2 = Vector2.ZERO
) -> void :
	scale.x = scale.x * direction_x
	global_position = glob_position
	
	match name_hit:
		"hit1":
			name_hit = RNGTools.pick(["hit1_a", "hit1_b", "hit1_c"])
		"hit2":
			name_hit = RNGTools.pick(["hit2_a", "hit2_b"])
		"weak":
			name_hit = "weak"
		
	Anim.play(name_hit)

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void :
	queue_free()
