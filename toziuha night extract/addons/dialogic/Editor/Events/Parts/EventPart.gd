tool 
extends Control


var editor_reference

var event_data = {}

signal data_changed


signal request_set_body_enabled(enabled)


signal request_open_body
signal request_close_body


signal request_selection


signal set_warning(text)
signal remove_warning()



func _ready():
	pass


func load_data(data: Dictionary):
	event_data = data



func get_preview_text():
	return ""


func focus():
	pass


func data_changed():
	emit_signal("data_changed", event_data)

