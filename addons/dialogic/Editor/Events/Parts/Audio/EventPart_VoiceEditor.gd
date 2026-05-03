tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"


export (PackedScene) var audio_picker



var audio_lines = 1


func load_data(data):
	.load_data(data)
	
	update_data()

func repopulate() -> void :
	for child in $List.get_children():
		child.queue_free()
	
	var settings = DialogicResources.get_settings_config()
	
	for i in range(audio_lines):
		var label = Label.new()
		label.text = "Line " + str(i + 1) + ":"
		label.size_flags_vertical = 0
		$List.add_child(label)
		
		var a_picker = audio_picker.instance()
		a_picker.editor_reference = editor_reference
		a_picker.event_name = "voice line"
		a_picker.connect("data_changed", self, "_on_audio_picker_audio_loaded", [i])
		$List.add_child(a_picker)
		
		
		if event_data.has("voice_data"):
			var voice_data = event_data["voice_data"]
			if voice_data.has(str(i)):
				var _d = voice_data[str(i)]
				if _d.has("file"):
					a_picker.load_data(_d)
					continue
		
		a_picker.load_data({"file": "", "audio_bus": settings.get_value("dialog", "text_event_audio_default_bus", "Master")})


func _on_text_changed(text: String) -> void :
	
	
	var settings_file = DialogicResources.get_settings_config()
	
	if not (settings_file.get_value("dialog", "new_lines", true)):
		$Label.text = "Audio Picker:"
		return
	
	var prev_lines = audio_lines
	$Label.text = "Audio Pickers:"
	audio_lines = max(1, len(text.split("\n")))
	
	if prev_lines != audio_lines:
		repopulate()



func _get_audio_picker(index: int):
	var data = $List.get_child(index * 2 + 1)
	return data

func _on_audio_picker_audio_loaded(data, index: int) -> void :
	
	if not event_data.has("voice_data"):
		event_data["voice_data"] = {}
	
	event_data["voice_data"][str(index)] = data
	
	
	load_data(event_data)
	
	
	data_changed()


func update_data():
	if not event_data.has("voice_data"):
		return
	var keys = event_data["voice_data"].keys()
	
	
	
	
	for i in range($List.get_child_count() / 2):
		if keys.has(str(i)):
			var data = event_data["voice_data"][str(i)]
			
			_get_audio_picker(i).load_data(data)
