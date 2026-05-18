tool 

extends CanvasLayer

export var speed: float = 0.5 setget set_speed
export var layers: int = 20 setget set_layers
export var modulate: Color = Color.white setget set_modulate

func set_modulate(modu: Color) -> void :
	modulate = modu
	$ColorRect.modulate = modu

func set_speed(sp: float) -> void :
	speed = sp
	$ColorRect.material = $ColorRect.material.duplicate()
	$ColorRect.material.set_shader_param("speed", sp)

func set_layers(lyr: int) -> void :
	layers = lyr
	$ColorRect.material = $ColorRect.material.duplicate()
	$ColorRect.material.set_shader_param("num_of_layers", lyr)
