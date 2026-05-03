extends ParallaxBackground

var hour: int = 12

func _ready() -> void :
	if Config.get_value("video", "vfx_level", 1) < 2:
		$ParallaxLayer2 / Waves.visible = false
	









	
