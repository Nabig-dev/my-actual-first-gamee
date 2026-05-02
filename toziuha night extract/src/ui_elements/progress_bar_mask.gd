tool 

extends Light2D


export (float, 0.0, 100.0) var value = 100.0 setget update_value





func update_value(progress_value: float) -> void :
	if texture == null:
		return
	
	
	var mask_size_x: float = texture.get_size().x / 2.0
	
	
	
	
	var percent: float = (progress_value * (mask_size_x / 100.0))
	
	value = progress_value
	
	
	$Sprite.position.x = percent - mask_size_x
