extends Control

var ModLoader: = preload("res://src/scripts/mod_loader.gd").new()

func _notification(what: int) -> void :
	if what == NOTIFICATION_EXIT_TREE:
		ModLoader.queue_free()

func _ready() -> void :
	
	ModLoader.load_mods()
	
	
	
	
	
	
	if Features.has("debug") == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	SceneChanger.change_scene("res://src/screens/splashscreen.tscn")
