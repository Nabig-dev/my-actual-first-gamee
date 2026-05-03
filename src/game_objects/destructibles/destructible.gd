extends Node2D

export var destruction_sound_name: String = "torch_destroyed_slash"

onready var Hurtbox = $HurtboxDestruct
onready var Anim = $AnimationPlayer

func _ready() -> void :
	Anim.play("show")

func _on_HurtboxDestruct_area_entered(_area: Area2D) -> void :
	Audio.play_sfx(destruction_sound_name)
	VarsGlobal.GameScenario.show_hit_lines(
		"hit_low", 1, global_position
	)
	Hurtbox.set_deferred("monitoring", false)
	Hurtbox.set_deferred("monitorable", false)
	Anim.play("destroyed")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	if anim_name == "destroyed":
		queue_free()
