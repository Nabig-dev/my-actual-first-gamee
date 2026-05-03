extends Node2D

var anim_name = "hit_low"

func _ready() -> void :
	rotation_degrees = RNGTools.randi_range(0, 360)
	
	$hit_low.visible = false
	$hit_mid.visible = false
	$hit_high.visible = false
	
	$AnimationPlayer.play(anim_name)

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void :
	queue_free()
