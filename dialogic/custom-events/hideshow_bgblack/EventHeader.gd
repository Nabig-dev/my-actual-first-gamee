tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"

onready var Chk = $CheckBox

func _ready() -> void :
	Chk.connect("toggled", self, "_on_checkbox_toggled")

func load_data(data: Dictionary):
	.load_data(data)
	if event_data.has("bg_visible") == false:
		event_data["bg_visible"] = true
	Chk.pressed = event_data["bg_visible"]

func _on_checkbox_toggled(press: bool) -> void :
	event_data["bg_visible"] = press
	data_changed()
