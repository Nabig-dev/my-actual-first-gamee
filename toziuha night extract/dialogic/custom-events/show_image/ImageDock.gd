extends Control

var image_path: String

func _ready() -> void :
	if image_path.empty() == false:
		$TextureRect.texture = load(image_path)
		$AnimationPlayer.play("show")
func hide_image() -> void :
	$AnimationPlayer.play_backwards("show")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
