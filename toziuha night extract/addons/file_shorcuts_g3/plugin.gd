tool 
extends EditorPlugin

var dock

func _enter_tree() -> void :
	
	dock = preload("res://addons/file_shorcuts_g3/dock.tscn").instance()
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, dock)
	
	get_tree().set_meta("editor_interface", get_editor_interface())

func _exit_tree() -> void :
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, dock)
	dock.free()
