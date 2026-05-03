extends Node


var sound_nodes: Dictionary

var effects_idx: int = AudioServer.get_bus_index("Effects")
var music_idx: int = AudioServer.get_bus_index("Music")
var voice_idx: int = AudioServer.get_bus_index("Voice")


var _current_music: String = "silence"

onready var TweenFade = $Tween
onready var Sounds = $Sfx.get_children()
onready var Musics = $Bgm.get_children()
onready var Voice = $Voice.get_children()

onready var TimerHitFilterAudio = $TimerHitFilterAudio

func _ready() -> void :
	
	
	
	var all_sounds = Sounds
	all_sounds.append_array(Musics)
	all_sounds.append_array(Voice)
	for s in all_sounds:
		
		if "volume_db" in s and s.editor_description == "":
			s.editor_description = String(s.volume_db)
		
		sound_nodes[s.name] = s


func set_enabled_reverb(rev_enabled: bool = true) -> void :
	AudioServer.set_bus_effect_enabled(
		effects_idx, 0, rev_enabled
	)
	AudioServer.set_bus_effect_enabled(
		voice_idx, 1, rev_enabled
	)

func underwater_filter_enabled(
	underw_filter_enable: bool = true
) -> void :

	AudioServer.set_bus_effect_enabled(
		effects_idx, 1, underw_filter_enable
	)
	AudioServer.set_bus_effect_enabled(
		voice_idx, 2, underw_filter_enable
	)

func hit_filter_audio_start(just_music_filter: bool = false) -> void :
	
	AudioServer.set_bus_effect_enabled(
		music_idx, 0, true
	)
	Engine.time_scale = 0.1
	yield(get_tree().create_timer(0.05), "timeout")
	Engine.time_scale = 1
	TimerHitFilterAudio.start(1)
	
	if just_music_filter == true:
		return
	
	AudioServer.set_bus_effect_enabled(
		effects_idx, 2, true
	)
	AudioServer.set_bus_effect_enabled(
		voice_idx, 3, true
	)




	









func sfx_is_playing(name_sfx: String) -> bool:
	return sound_nodes[name_sfx].is_playing()

func play_sfx(
	name_sfx: String, 
	fadein: bool = false, 
	duration_fade: float = 1
) -> void :
	
	if fadein:
		_apply_fade(sound_nodes[name_sfx], "in", duration_fade)
	
	sound_nodes[name_sfx].play()

func stop_sfx(name_sfx: String, fadeout: bool = false, duration_fade: float = 1) -> void :
	
	if fadeout:
		_apply_fade(sound_nodes[name_sfx], "out", duration_fade)
	
	else:
		sound_nodes[name_sfx].stop()

func play_voice(name_voice: String) -> void :
	sound_nodes[name_voice].play()
	
func play_music(
	name_music: String, 
	opt: String = "high", 
	duration_fade: float = 3.0, 
	restart: bool = false
) -> void :
	
	_current_music = name_music
	
	
	if name_music == "silence":
		stop_music()
		return
	
	
	for m in Musics:
		
		if restart == false and m.name == name_music:
			pass
		else:
			sound_nodes[m.name].stop_all(duration_fade)

	sound_nodes[name_music].play(opt, duration_fade)

func stop_music(name_music: String = "all", duration_fade: float = 3.0) -> void :
	
	var music_nodes: Array
	
	if name_music == "all":
		_current_music = "silence"
		music_nodes = Musics
	else:
		music_nodes.append(sound_nodes[name_music])

	for m in music_nodes:
		sound_nodes[m.name].stop_all(duration_fade)


func change_music_style(opt: String = "high") -> void :
	if _current_music == "silence":
		return
	
	if sound_nodes[_current_music].is_stopped() == false:
		sound_nodes[_current_music].play(opt, 3.0)


func _apply_fade(audiostream, type: String = "in", duration: float = 1) -> void :
	
	
	var initial_volume: float = - 80.0
	var original_volume: float = 0.0
	
	if "volume_db" in audiostream and audiostream.editor_description != "":
		audiostream.volume_db = initial_volume
		original_volume = float(audiostream.editor_description)
	
	else:
		return
	
		
	if type == "in":
		TweenFade.interpolate_property(
			audiostream, 
			"volume_db", 
			initial_volume, 
			original_volume, 
			duration
		)
	elif type == "out":
		TweenFade.interpolate_property(
			audiostream, 
			"volume_db", 
			original_volume, 
			initial_volume, 
			duration
		)
	TweenFade.start()

func _on_Tween_tween_completed(object: Object, key: NodePath) -> void :
	
	
	if key == "volume_db" and object is AudioStreamPlayer or AudioStreamPlayer2D and object.volume_db <= - 20.0:
		object.stop()


func _on_TimerHitFilterAudio_timeout() -> void :
	AudioServer.set_bus_effect_enabled(
		effects_idx, 2, false
	)
	AudioServer.set_bus_effect_enabled(
		music_idx, 0, false
	)
	AudioServer.set_bus_effect_enabled(
		voice_idx, 3, false
	)
