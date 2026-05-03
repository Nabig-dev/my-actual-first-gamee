tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"

onready var Chk = $CheckBox

func _ready() -> void :
	Chk.connect("toggled", self, "_on_checkbox_toggled")

func load_data(data: Dictionary):
	.load_data(data)
	if event_data.has("skip_disabled") == false:
		event_data["skip_disabled"] = true
	Chk.pressed = event_data["skip_disabled"]

func _on_checkbox_toggled(press: bool) -> void :
	event_data["skip_disabled"] = press
	data_changed()

