tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"
	

	
	
onready var input_field = $InputField

	
func _ready():
	
	input_field.connect("text_changed", self, "_on_InputField_text_changed")
	
	
	
func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	
	input_field.text = event_data["image_path"]

	
func get_preview():
	return ""

	
func _on_InputField_text_changed(text):
	event_data["image_path"] = text
	
	
	data_changed()
