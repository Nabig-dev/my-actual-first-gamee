tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"

onready var Action = $MenuButton
onready var Type = $MenuButton2
onready var AudioName = $LineEdit

func _ready() -> void :
	AudioName.connect("text_changed", self, "_on_audio_name_changed")
	Type.get_popup().connect("index_pressed", self, "_on_type_changed")
	Action.get_popup().connect("index_pressed", self, "_on_action_changed")

func load_data(data: Dictionary):
	.load_data(data)
	
	if event_data.has("audio_name") == false:
		event_data["audio_name"] = ""
	AudioName.text = event_data["audio_name"]
	
	if event_data.has("action") == false:
		event_data["action"] = 0
	Action.get_popup().set_current_index(event_data["action"])
	_on_action_changed(event_data["action"])
	
	if event_data.has("type") == false:
		event_data["type"] = 0
	Type.get_popup().set_current_index(event_data["type"])
	_on_type_changed(event_data["type"])

func _on_audio_name_changed(audio_name: String) -> void :
	event_data["audio_name"] = audio_name
	data_changed()
func _on_type_changed(type: int) -> void :
	Type.text = Type.get_popup().get_item_text(Type.get_popup().get_current_index())
	event_data["type"] = type
	data_changed()
func _on_action_changed(action: int) -> void :
	Action.text = Action.get_popup().get_item_text(Action.get_popup().get_current_index())
	event_data["action"] = action
	data_changed()
