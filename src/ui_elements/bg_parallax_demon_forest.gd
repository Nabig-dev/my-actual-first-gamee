extends ParallaxBackground

export var modulate: Color

var _bg_offset_x: float = 0

func _ready() -> void :
	$ParallaxLayer.modulate = modulate
	$ParallaxLayer2.modulate = modulate
	$ParallaxLayer3.modulate = modulate
	$ParallaxLayer4.modulate = modulate

func _process(delta: float) -> void :
	
	_bg_offset_x -= 20 * delta
	set_scroll_offset(Vector2(_bg_offset_x, 0))
