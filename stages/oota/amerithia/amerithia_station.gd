extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	
	if VarsGlobal.has_flag("alessa_talk_office1") == false:
		VarsGlobal.GameScenario.get_node("TrainStation").active = false
	
	elif VarsGlobal.has_flag("train_event_finished") == false:
		VarsGlobal.GameScenario.get_node("TrainStation").go_to_train_event = true


func _on_TrainStation_interact_requested() -> void :
	
	if VarsGlobal.has_flag("train_event_finished") == false:
		
		VarsGlobal.current_room_changer = ""
		VarsGlobal.current_building_door = ""
		VarsGlobal.game_data.current_room_changer = ""
		VarsGlobal.game_data.current_building_door = ""
		VarsGlobal.game_data["player_facing"] = 1
		VarsGlobal.Player.velocity.x = 0
