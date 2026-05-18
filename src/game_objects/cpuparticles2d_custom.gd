extends CPUParticles2D

export var pre_emit: bool = true

var _emitting: bool
var _visible: bool

func _enter_tree() -> void :
	
	if pre_emit == false:
		return
	
	_visible = visible
	_emitting = emitting
	
	
	visible = false
	emitting = true
	
	visible = _visible
	emitting = _emitting
