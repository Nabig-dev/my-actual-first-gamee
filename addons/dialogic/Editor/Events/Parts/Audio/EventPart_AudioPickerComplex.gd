tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"




onready var audio_picker = $VBox / AudioPicker
onready var fade_length_input = $VBox / Fade / FadeLength


func _ready():
	audio_picker.connect("data_changed", self, "_on_AudioPicker_data_changed")
	fade_length_input.connect("value_changed", self, "_on_FadeLength_value_changed")


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	audio_picker.editor_reference = editor_reference
	audio_picker.load_data(event_data)
	
	fade_length_input.value = event_data["fade_length"]


func get_preview():
	return audio_picker.get_preview()

func _on_AudioPicker_data_changed(data):
	event_data = data
	
	
	data_changed()

func _on_FadeLength_value_changed(value):
	event_data["fade_length"] = value
	audio_picker.load_data(event_data)
	
	
	data_changed()
	
