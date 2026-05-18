extends ColorRect

export var auto_hide: = true


func _ready() -> void :
	if auto_hide:
		visible = true
		modulate.a = 0
		
