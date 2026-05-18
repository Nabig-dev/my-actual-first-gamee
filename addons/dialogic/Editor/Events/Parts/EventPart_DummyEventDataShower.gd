tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"




onready var text_field = $EventId


func _ready():
	pass


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	text_field.text = event_data["event_id"]


func get_preview():
	return ""
