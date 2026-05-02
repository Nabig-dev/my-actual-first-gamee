tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"



onready var character_picker = $HBox / CharacterPicker
onready var portrait_picker = $HBox / PortraitPicker
onready var definition_picker = $HBox / DefinitionPicker


func _ready():
	if DialogicUtil.get_character_list().size() == 0:
		hide()
	character_picker.connect("data_changed", self, "_on_CharacterPicker_data_changed")
	portrait_picker.connect("data_changed", self, "_on_PortraitPicker_data_changed")
	definition_picker.connect("data_changed", self, "_on_DefinitionPicker_data_changed")
	

func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	portrait_picker.load_data(data)
	character_picker.load_data(data)
	
	portrait_picker.visible = get_character_data() and len(get_character_data()["portraits"]) > 1
	
	if data["event_id"] == "dialogic_002":
		if data.get("type", 0) != 1:
			var has_port_defn = data["portrait"] == "[Definition]"
			if portrait_picker.visible and has_port_defn and data.has("port_defn"):
				definition_picker.load_data({"definition": data["port_defn"]})
			definition_picker.visible = has_port_defn
		else:
			portrait_picker.hide()
			definition_picker.hide()


func get_preview():
	return ""


func get_character_data():
	for ch in DialogicUtil.get_character_list():
		if ch["file"] == event_data["character"]:
			return ch


func _on_CharacterPicker_data_changed(data):
	event_data = data
	
	
	portrait_picker.load_data(data)
	portrait_picker.visible = get_character_data() and len(get_character_data()["portraits"]) > 1
	if not portrait_picker.visible:
		definition_picker.hide()
	
	
	data_changed()


func _on_PortraitPicker_data_changed(data):
	event_data = data
	
	
	character_picker.load_data(data)
	definition_picker.visible = event_data["portrait"] == "[Definition]"
	
	
	data_changed()


func _on_DefinitionPicker_data_changed(data):
	event_data["port_defn"] = data["definition"]

	
	data_changed()
