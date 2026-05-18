extends Node

export var high_tracks: String = "0"

export var low_tracks: String = "0"

var Tw: Tween

var audio_tracks: Array = []

var _low_tracks: Array
var _high_tracks: Array

var _all_is_stopped: bool = true

func _ready() -> void :
	
	
	var tween_node = Tween.new()
	add_child(tween_node)
	Tw = tween_node
	Tw.connect("tween_completed", self, "_on_Tween_tween_completed")

	_low_tracks = low_tracks.split(",")
	_high_tracks = high_tracks.split(",")
	
	for track in get_children():
		if track is AudioStreamPlayer:
			
			track.editor_description = str(track.volume_db)
			
			track.volume_db = - 80.0
			
			audio_tracks.append(track)

func is_stopped() -> bool:
	return _all_is_stopped

func play_track(track: int, fadein_time: float = 1.0) -> void :
	_play_muted_all()
	if fadein_time >= 0.0:
		_fade(audio_tracks[track], true, fadein_time)

func stop_track(track: int, fadeout_time: float = 1.0) -> void :
	_fade(audio_tracks[track], false, fadeout_time)

func play(opt: String = "high", fadein_time: float = 1.0) -> void :
	var i: int = 0
	var track_list: Array
	
	if opt == "high":
		stop("low", fadein_time)
		track_list = _high_tracks
	
	elif opt == "low":
		stop("high", fadein_time)
		track_list = _low_tracks
	
	elif opt.is_valid_integer() == true:
		track_list.append(int(opt))
	
	
	_play_muted_all()
	
	
	for t in audio_tracks:
		
		
		if str(i) in track_list:
			_fade(audio_tracks[i], true, fadein_time)
		
		i += 1

func stop(opt: String = "high", fadeout_time: float = 1.0) -> void :
	var i: int = 0
	var track_list: Array
	
	if opt == "high":
		track_list = _high_tracks
	elif opt == "low":
		track_list = _low_tracks
	
	
	for t in audio_tracks:
		
		
		if str(i) in _high_tracks and str(i) in _low_tracks:
			pass
		
		
		elif str(i) in track_list:
			_fade(audio_tracks[i], false, fadeout_time)
			
		i += 1

func play_all(fadein_time: float = 1.0) -> void :
	for t in audio_tracks:
		_fade(t, true, fadein_time)
		t.play()
	_all_is_stopped = false

func stop_all(fadeout_time: float = 1.0):
	if _all_is_stopped == true:
		return
	for t in audio_tracks:
		_fade(t, false, fadeout_time)
	_all_is_stopped = true

func _play_muted_all() -> void :
	
	if _all_is_stopped == false:
		return
	
	for t in audio_tracks:
		t.volume_db = - 80.0
		t.play()

	_all_is_stopped = false

func _original_db(audiotrack: AudioStreamPlayer) -> float:
	return float(audiotrack.editor_description)

func _fade(audiotrack: AudioStreamPlayer, fadein: bool = true, time: float = 0.5) -> void :

	
	var from_db: float = audiotrack.volume_db
	var to_db: float = _original_db(audiotrack)
	var easetw: int = Tween.EASE_OUT
	
	var transtw: int = Tween.TRANS_EXPO
	
	
	if fadein == false:
		from_db = audiotrack.volume_db
		to_db = - 80.0
		easetw = Tween.EASE_IN
	
	
	
	Tw.remove(audiotrack, "volume_db")
	
	Tw.interpolate_property(
		audiotrack, "volume_db", from_db, to_db, time, transtw, easetw
	)

	Tw.start()

func _on_Tween_tween_completed(object: Object, key: NodePath) -> void :
	if (
		key == ":volume_db" and 
		object is AudioStreamPlayer and 
		object.volume_db == - 80 and 
		_all_is_stopped == true
	):
		object.stop()
