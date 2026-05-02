tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"




onready var input_field = $HBox / ChoiceText
onready var condition_picker = $ConditionPicker


func _ready():
	
	input_field.connect("text_changed", self, "_on_ChoiceText_text_changed")
	condition_picker.connect("data_changed", self, "_on_ConditionPicker_data_changed")
	condition_picker.connect("remove_warning", self, "emit_signal", ["remove_warning"])
	condition_picker.connect("set_warning", self, "set_warning")


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	input_field.text = event_data["choice"]
	
	
	condition_picker.load_data(event_data)
	


func get_preview():
	return ""


func _on_ChoiceText_text_changed(text):
	event_data["choice"] = text
	
	
	data_changed()

func _on_ConditionPicker_data_changed(data):
	event_data = data
	
	data_changed()

func set_warning(text):
	emit_signal("set_warning", text)
