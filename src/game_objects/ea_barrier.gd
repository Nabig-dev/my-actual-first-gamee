extends Node2D

func _ready() -> void :
	
	if VarsGlobal.get_version_status() != "early_access":
		queue_free()
