tool 

extends ParallaxBackground

export var modulate: Color = Color.white setget set_modulate
export var speed: int = 10
export (int, "-1", "1") var dir = - 1

var motion: Vector2

onready var MistUp: = $MistUp
onready var MistDown: = $MistDown

func _process(delta: float) -> void :
	
	if Engine.is_editor_hint() == true:
		return
	
	motion = Vector2( - speed, 0)
	motion *= delta
	
	MistUp.motion_offset += motion * dir
	MistDown.motion_offset += motion * (dir * - 1)

func set_modulate(modu: Color) -> void :
	modulate = modu
	
	if get_node_or_null("MistDown/Fog") != null:
		$MistDown / Fog.modulate = modulate
		$MistUp / Fog.modulate = modulate
