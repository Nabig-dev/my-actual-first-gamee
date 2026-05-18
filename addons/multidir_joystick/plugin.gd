tool 
extends EditorPlugin

var joyustick: = preload("res://addons/multidir_joystick/scene/joystick.tscn")

func _enter_tree() -> void :
	add_custom_type("VirtualJoystick", "Node2D", preload("res://addons/multidir_joystick/scripts/joystick.gd"), preload("res://addons/multidir_joystick/icons/icon.svg"))

func _exit_tree() -> void :
	remove_custom_type("VirtualJoystick")

