tool 

extends ParallaxBackground

export var modulate: Color = Color.white setget set_modulate


func set_modulate(modu: Color) -> void :
	var layers: Array = [
		"ParallaxLayer", 
		"ParallaxLayer2", 
		"ParallaxLayer3", 
		"ParallaxLayer4", 
		"ParallaxLayer5", 
	]
	modulate = modu
	for l in layers:
		if get_node_or_null(l) != null:
			get_node(l).modulate = modulate
