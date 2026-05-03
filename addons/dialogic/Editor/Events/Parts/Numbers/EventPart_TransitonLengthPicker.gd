tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"




onready var number_box = $HBox / NumberBox


func _ready():
	number_box.connect("value_changed", self, "_on_NumberBox_value_changed")


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	number_box.value = event_data["transition_duration"]


func get_preview():
	return ""

func _on_NumberBox_value_changed(value):
	event_data["transition_duration"] = value
	
	
	data_changed()
