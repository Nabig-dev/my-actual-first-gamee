extends Node

var FilterScreens = {
	1: preload("res://dialogic/custom-events/screen_dialog_filter/flashback_filter_control.tscn")
}

func handle_event(event_data, dialog_node):
	
	
	if event_data["filter_idx"] > 0:
		var FilterInstance = FilterScreens[int(event_data["filter_idx"])].instance()
		dialog_node.get_node("ScreenFilterLayer").add_child(FilterInstance)

	
	else:
		get_tree().call_group("dialogic_screen_filter", "queue_free")
	
	
	dialog_node._load_next_event()
	dialog_node.set_state(dialog_node.state.READY)
