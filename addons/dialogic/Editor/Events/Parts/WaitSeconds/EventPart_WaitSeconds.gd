tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"




onready var seconds_selector = $HBoxContainer / SecondsBox
onready var skippable_selector = $HBoxContainer / SkippableCheckbox
onready var hideBox_selector = $HBoxContainer / HideDialogBoxCheckbox


func _ready():
	seconds_selector.connect("value_changed", self, "_on_SecondsSelector_value_changed")
	skippable_selector.connect("toggled", self, "_on_SkippableSelector_toggled")
	hideBox_selector.connect("toggled", self, "_on_HideDialogBox_toggled")


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	seconds_selector.value = event_data["wait_seconds"]
	skippable_selector.pressed = event_data.get("waiting_skippable", false)
	hideBox_selector.pressed = event_data.get("hide_dialogbox", true)
	if event_data["wait_seconds"] == 1:
		$HBoxContainer / Label2.text = "second"
	else:
		$HBoxContainer / Label2.text = "seconds"

func _on_SecondsSelector_value_changed(value):
	event_data["wait_seconds"] = value
	if value == 1:
		$HBoxContainer / Label2.text = "second"
	else:
		$HBoxContainer / Label2.text = "seconds"
	data_changed()

func _on_SkippableSelector_toggled(checkbox_value):
	event_data["waiting_skippable"] = checkbox_value
	data_changed()

func _on_HideDialogBox_toggled(checkbox_value):
	event_data["hide_dialogbox"] = checkbox_value
	data_changed()


func get_preview():
	return ""
