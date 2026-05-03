extends Control








func _on_FlashbackFilter_resized() -> void :
	var screen = get_viewport().size
	var center = Vector2(screen.x / 2, screen.y / 2)
	$AnimatedSprite.position = center
