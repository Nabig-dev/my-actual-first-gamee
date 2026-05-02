extends Node


func handle_event(event_data, dialog_node):

	if event_data["audio_name"] != "":
	
		if event_data["action"] == 0:
			if event_data["type"] == 0:
				Audio.play_sfx(event_data["audio_name"])
			else:
				Audio.play_music(event_data["audio_name"])
		
		else:
			if event_data["type"] == 0:
				Audio.stop_sfx(event_data["audio_name"])
			else:
				Audio.stop_music(event_data["audio_name"])
	
	dialog_node._load_next_event()
	dialog_node.set_state(dialog_node.state.READY)
