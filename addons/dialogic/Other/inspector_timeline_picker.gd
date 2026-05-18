extends EditorInspectorPlugin

var TimelinePicker = preload("res://addons/dialogic/Other/timeline_picker.gd")
var dialogic_editor_plugin = null
var dialogic_editor_view = null


func can_handle(object):
	
	return true


func parse_property(object, type, path, hint, hint_text, usage):
	
	if hint_text == "TimelineDropdown":
		
		if type == TYPE_STRING:
			
			
			var picker = TimelinePicker.new()
			picker.editor_inspector_plugin = self
			add_property_editor(path, picker)
			
			
			return true
		return false


func switch_to_dialogic_timeline(timeline: String):
	if (dialogic_editor_plugin != null):
		var master_tree = dialogic_editor_view.get_node("MainPanel/MasterTreeContainer/MasterTree")
		dialogic_editor_plugin.get_editor_interface().set_main_screen_editor("Dialogic")

		master_tree.timeline_editor.batches.clear()
		master_tree.timeline_editor.load_timeline(timeline)
		master_tree.show_timeline_editor()
