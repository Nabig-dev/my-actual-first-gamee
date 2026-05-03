tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"

onready var input_time = $SpinBox

func _ready():
	input_time.connect("value_changed", self, "_on_time_changed")

func load_data(data: Dictionary):
	.load_data(data)
	if event_data.has("time_flash") == false:
		event_data["time_flash"] = 0.5
	input_time.value = event_data["time_flash"]


func _on_time_changed(time: float):
	event_data["time_flash"] = time
	data_changed()
