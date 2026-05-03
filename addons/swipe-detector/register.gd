tool 
extends EditorPlugin

func _enter_tree():
	
	
	add_custom_type("SwipeDetector", "Node", preload("swipe_detector.gd"), preload("icon.png"))
	print("Registered SwipeDetector")

func _exit_tree():
	
	
	remove_custom_type("SwipeDetector")