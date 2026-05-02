tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"




onready var file_picker = $HBox / FilePicker

onready var fade_duration_label = $HBox / FadeLabel
onready var fade_duration = $HBox / NumberBox


func _ready():
	file_picker.connect("data_changed", self, "_on_FilePicker_data_changed")
	fade_duration.connect("value_changed", self, "_on_fade_duration_changed")




func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	file_picker.load_data(data)
	if event_data["background"]:
		fade_duration_label.visible = true
		fade_duration.visible = true
		emit_signal("request_close_body")
	else:
		fade_duration_label.visible = false
		fade_duration.visible = false
		emit_signal("request_close_body")

	fade_duration.value = event_data.get("fade_duration", 1)


func get_preview():
	return ""

func _on_FilePicker_data_changed(data):
	event_data = data
	
	fade_duration.visible = not data["background"].empty()
	fade_duration_label.visible = not data["background"].empty()

	if not data["background"].empty():
		emit_signal("request_open_body")
	else:
		emit_signal("request_close_body")
		
	
	data_changed()
















func _on_fade_duration_changed(value: float):
	event_data["fade_duration"] = value
	
	data_changed()
