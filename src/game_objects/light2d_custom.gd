extends Light2D

export var only_light2d: bool = true

onready var AdditiveLight = $AdditiveLight

func _ready() -> void :
	
	
	
	if Config.get_value("video", "vfx_level", 1) < 2:
		
		enabled = false
		
		
		if only_light2d == true:
			return
		
		
		AdditiveLight.texture = texture
		
		AdditiveLight.self_modulate = color
		
		AdditiveLight.scale = Vector2(texture_scale, texture_scale)
