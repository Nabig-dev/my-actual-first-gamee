tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"




onready var noskip_selector = $HBoxContainer / NoSkipCheckbox
onready var autoadvance_time = $HBoxContainer2 / AutoAdvanceTime


func _ready():
	autoadvance_time.connect("value_changed", self, "_on_SecondsSelector_value_changed")
	noskip_selector.connect("toggled", self, "_on_HideDialogBox_toggled")


func load_data(data: Dictionary):
	
	.load_data(data)
	
	autoadvance_time.value = event_data["wait_time"]
	noskip_selector.pressed = event_data.get("block_input", true)


func _on_SecondsSelector_value_changed(value):
	event_data["wait_time"] = value
	data_changed()


func _on_HideDialogBox_toggled(checkbox_value):
	event_data["block_input"] = checkbox_value
	data_changed()


func get_preview():
	return ""
