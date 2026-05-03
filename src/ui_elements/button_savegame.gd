extends Button

export var save_slot: int

var empty_slot: bool = false

func _ready() -> void :
	
	if Savedata.game_exists(
		save_slot, 
		VarsGlobal.selected_stage
	) == false:
		empty_slot = true
		get_node("%LblName").text = tr("NEW_GAME")
		get_node("%LblScenarioName").visible = false
		get_node("%LblTime").visible = false
		get_node("%LblPercent").text = "%d %% " % [0]
		return

	

	var data = Savedata.get_game_resume(save_slot)
	
	get_node("%LblName").text = data["save_name"]
	get_node("%LblTime").text = "%s: %s" % [
		tr("TIME"), 
		Stopwatch.get_friendly_text_time(data["millis_elapsed"])
	]
	if data["scenario_name"] == "":
		get_node("%LblScenarioName").visible = false
	else:
		get_node("%LblScenarioName").text = "- %s -" % [data["scenario_name"]]
		

	get_node("%LblPercent").text = "%.2f %% " % [
		VarsGlobal.get_map_percentage(data["total_visited_tiles"])
	]
