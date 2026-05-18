tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"




onready var file_picker = $FilePicker


func _ready():
	file_picker.connect("data_changed", self, "_on_ScenePicker_data_changed")


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	file_picker.load_data(data)


func get_preview():
	return ""

func _on_ScenePicker_data_changed(data):
	event_data = data
	data_changed()

