extends ParallaxBackground

func _ready() -> void :
	if Config.get_value("video", "vfx_level", 1) < 2:
		$ParallaxLayer / VolcanoVaporA.visible = false
		$Waves.visible = false
		
