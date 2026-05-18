tool 
extends EditorPlugin

func _enter_tree() -> void :
	add_custom_type("Carousel Menu", "Node2D", preload("res://addons/carrousel_menu/CarrouselMenu.gd"), preload("res://addons/carrousel_menu/icon.png"))

func _exit_tree() -> void :
	remove_custom_type("Carousel Menu")
