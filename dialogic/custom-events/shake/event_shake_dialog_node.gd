extends Node


func handle_event(_event_data, dialog_node):
	Gamepad.start_vibration(0, 0.8, 0.8, 0.3)
	dialog_node.play_shake()
	
	dialog_node._load_next_event()
	dialog_node.set_state(dialog_node.state.READY)
