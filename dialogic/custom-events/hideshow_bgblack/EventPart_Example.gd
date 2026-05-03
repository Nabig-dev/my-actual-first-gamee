tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"
	

	
	
onready var input_field = $InputField

	
func _ready():
	
	input_field.connect("text_changed", self, "_on_InputField_text_changed")
	pass

	
func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	
	input_field.text = event_data["my_text_key"]

	
func get_preview():
	return ""

	
func _on_InputField_text_changed(text):
	event_data["my_text_key"] = text
	
	
	data_changed()
