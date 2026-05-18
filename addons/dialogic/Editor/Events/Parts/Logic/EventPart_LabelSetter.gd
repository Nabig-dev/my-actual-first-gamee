tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"

onready var input_field = $NameInput
onready var new_id = $NewIdButton

func _ready():
	input_field.connect("text_changed", self, "_on_InputField_text_changed")
	new_id.icon = get_icon("RotateRight", "EditorIcons")
	new_id.connect("pressed", self, "new_id")

func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	if data["id"] == null or data["id"] == "":
		new_id()
	input_field.text = event_data["name"]
	
	new_id.hint_tooltip = "Change to a new unique ID. \nOnly do this if you have a duplicate id in this timeline! \nWill break existing links. \n\nCurrent ID: " + data["id"]

func new_id():
	event_data["id"] = "anchor-" + str(OS.get_unix_time())
	
	new_id.hint_tooltip = "Change to a new unique ID. \nOnly do this if you have a duplicate id in this timeline! \nWill break existing links. \n\nCurrent ID: " + event_data["id"]
	data_changed()

func _on_InputField_text_changed(text):
	event_data["name"] = text
	
	
	data_changed()
