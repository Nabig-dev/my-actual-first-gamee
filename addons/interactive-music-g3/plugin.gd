tool 
extends EditorPlugin

func _enter_tree() -> void :
	
	
	add_custom_type("AudioStreamPlayerInteractive", "Node", preload("res://addons/interactive-music-g3/audio_stream_player_interactive.gd"), preload("res://addons/interactive-music-g3/icon.png"))

func _exit_tree() -> void :
	
	
	remove_custom_type("AudioStreamPlayerInteractive")
