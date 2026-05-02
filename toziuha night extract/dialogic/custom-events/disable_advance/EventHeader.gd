tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"

onready var ChckBx = $CheckBox

func _ready():
	ChckBx.connect("toggled", self, "_on_checkbox_toggled")

func load_data(data: Dictionary):
	.load_data(data)
	if event_data.has("input_enabled") == false:
		event_data["input_enabled"] = false
	ChckBx.pressed = event_data["input_enabled"]

func _on_checkbox_toggled(press: bool):
	event_data["input_enabled"] = press
	data_changed()
