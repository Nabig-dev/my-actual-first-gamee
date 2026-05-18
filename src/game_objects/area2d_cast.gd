extends Area2D

signal object_entered(Obj)
signal object_exited(Obj)

export var enabled: bool = true

export (int, "Area", "Body") var detect = 0

var _entered: bool

func _ready() -> void :
	
	if enabled == false:
		return
	
	
	if detect == 0:
		
		connect("area_entered", self, "_on_entered")
		
		connect("area_exited", self, "_on_exited")

	
	else:
		
		connect("body_entered", self, "_on_entered")
		
		connect("body_exited", self, "_on_exited")

func is_colliding() -> bool:
	if enabled == false:
		return false
	return _entered

func _on_entered(Obj: Object) -> void :
	modulate = Color("ff0000")
	_entered = true
	emit_signal("object_entered", Obj)

func _on_exited(Obj: Object) -> void :
	modulate = Color("ffffff")
	_entered = false
	emit_signal("object_exited", Obj)
