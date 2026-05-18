tool 

extends Node2D

export var color: Color = Color.black setget _update_color
export var vignette_scale: float = 0.03 setget _update_vignette_scale

export var vignette_extra_scale: float = 0.0 setget _update_vignette_extra_scale

var running_on_editor: bool

var enabled: bool

var _Player: Object

onready var ClrRect = $ColorRect

func _ready() -> void :
	running_on_editor = Engine.editor_hint

	if running_on_editor == true:
		visible = false
	else:
		visible = true

func _physics_process(_delta: float) -> void :
	
	if running_on_editor == true or VarsGlobal.Player == null or enabled == false:
		return
	global_position = VarsGlobal.Player.global_position
	

func _update_color(clr: Color) -> void :
	if get_node_or_null("ColorRect") != null:
		color = clr
		$ColorRect.material = $ColorRect.material.duplicate()
		$ColorRect.material.set_shader_param("color", color)

func _update_vignette_scale(scl: float) -> void :
	if get_node_or_null("ColorRect") != null:
		vignette_scale = scl
		$ColorRect.material = $ColorRect.material.duplicate()
		$ColorRect.material.set_shader_param("SCALE", vignette_scale + vignette_extra_scale)

func _update_vignette_extra_scale(extr_scale: float) -> void :
	vignette_extra_scale = extr_scale
	_update_vignette_scale(vignette_scale)

func _on_TimerStartFollowPlayer_timeout() -> void :
	if running_on_editor == false:
		enabled = true
		
