extends Node

var is_active: = false

var millis_elapsed: = 0.0

func _enter_tree() -> void :
	pause_mode = PAUSE_MODE_PROCESS

func _process(delta: float) -> void :
	
	if is_active == false:
		return
	
	millis_elapsed = (millis_elapsed + delta)

func start() -> void :
	millis_elapsed = 0.0
	is_active = true

func pause() -> void :
	is_active = false

func stop() -> void :
	is_active = false
	millis_elapsed = 0.0

func get_friendly_time(time: float) -> Dictionary:
	
	var dict_time: Dictionary
	dict_time["hours"] = int((time / 60) / 60)
	
	dict_time["minutes"] = int(fmod(floor(int(time) / 60), 60))
	dict_time["seconds"] = int(fmod(time, 60))
	dict_time["milliseconds"] = float(time - int(time))
	return dict_time

func convert_to_milli_int(millis: float) -> int:
	var secs_total: int = 0
	var millis_total: int = 0
	var time_friendly: Dictionary = get_friendly_time(millis)
	
	
	secs_total += time_friendly["seconds"]
	
	secs_total += time_friendly["minutes"] * 60
	
	secs_total += time_friendly["hours"] * 3600
	
	
	millis_total = (secs_total * 1000) + time_friendly["milliseconds"]

	return millis_total

func get_friendly_text_time(time: float) -> String:
	var time_dict = get_friendly_time(time)
	return "%dh %dm %ss %sms" % [
		time_dict["hours"], 
		time_dict["minutes"], 
		time_dict["seconds"], 
		str(stepify(time_dict["milliseconds"], 0.01)).replace("0.", ""), 
	]
