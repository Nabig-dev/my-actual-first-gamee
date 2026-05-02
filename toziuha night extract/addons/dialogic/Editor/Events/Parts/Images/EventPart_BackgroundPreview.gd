tool 
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"




onready var texture_rect = $Box / TextureRect


func _ready():
	pass


func load_data(data: Dictionary):
	
	.load_data(data)
	
	
	if event_data["background"]:
		if not event_data["background"].ends_with(".tscn"):
			emit_signal("request_set_body_enabled", true)
			texture_rect.texture = load(event_data["background"])
		else:
			emit_signal("request_set_body_enabled", false)
			if editor_reference and editor_reference.editor_interface:
				editor_reference.editor_interface.get_resource_previewer().queue_resource_preview(event_data["background"], self, "show_scene_preview", null)
	else:
		emit_signal("request_set_body_enabled", false)


func get_preview():
	return ""

func show_scene_preview(path: String, preview: Texture, user_data):
	if preview:
		texture_rect.texture = preview
		emit_signal("request_set_body_enabled", true)
		

