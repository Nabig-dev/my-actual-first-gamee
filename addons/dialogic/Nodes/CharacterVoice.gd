extends AudioStreamPlayer

var stop_time: float

func play_voice(data: Dictionary) -> void :
	if data == {}:
		stop_voice()
		return
	
	if data.has("volume"):
		volume_db = data["volume"]
	
	if data.has("audio_bus"):
		bus = data["audio_bus"]
	
	if data.has("file"):
		if data["file"] == "":
			stop_voice()
			return
		var s: AudioStream = load(data["file"])
		if s != null:
			stream = s
			
			if data.has("start_time"):
				play(data["start_time"])
			else:
				play()
			
			
			
			if data.has("stop_time"):
				stop_time = data["stop_time"]
				if stop_time <= 0:
					stop_time = s.get_length() - 0.1
			else:
				stop_time = s.get_length() - 0.1
		else:
			stop_voice()
func stop_voice():
	stop()

func remaining_time():
	if not playing:
		return 0
	return stop_time - get_playback_position()

	
func _process(_delta):
	
	if (playing and get_playback_position() >= stop_time):
		stop_voice()
