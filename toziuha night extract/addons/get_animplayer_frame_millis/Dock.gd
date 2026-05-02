tool 

extends Control

signal button_pressed(anim_name)

var Anim: AnimationPlayer

var selected_anim: String

func _enter_tree() -> void :
	$VBoxContainer / HBoxContainer2 / BtnCopyFramesData.disabled = true

func update_anim_list() -> void :
	
	if is_valid_animplayer() == false:
		return
	
	$VBoxContainer / LblAnimationName.text = "Current AnimPlayer: %s" % [Anim.name]
	
	var anim_list = Anim.get_animation_list()

	
	$VBoxContainer / OptionButtonAnimList.clear()
	
	$VBoxContainer / OptionButtonTracksList.clear()
	
	$VBoxContainer / HBoxContainer2 / BtnCopyFramesData.disabled = true
	
	for b in $VBoxContainer / ScrollContainer / HFlowContainerFrames.get_children():
		b.queue_free()
	
	
	$VBoxContainer / OptionButtonAnimList.add_item("- - -", 0)
	var i: int = 1
	for anim in anim_list:
		if anim != "RESET":
			$VBoxContainer / OptionButtonAnimList.add_item(anim, i)
		i += 1

func is_valid_animplayer() -> bool:
	var anim_valid: bool = is_instance_valid(Anim)
	if anim_valid == false:
		$VBoxContainer / LblAnimationName.text = "AnimPlayer Invalid!"
	return anim_valid

func _on_OptionButtonAnimList_item_selected(index: int) -> void :
	
	if is_valid_animplayer() == false:
		return
	
	$VBoxContainer / HBoxContainer2 / LblAnimTotalTime.text = "Time: 00ms"
	
	
	$VBoxContainer / OptionButtonTracksList.clear()
	
	$VBoxContainer / HBoxContainer2 / BtnCopyFramesData.disabled = true

	if index < 1:
		
		for b in $VBoxContainer / ScrollContainer / HFlowContainerFrames.get_children():
			b.queue_free()
		return
	
	selected_anim = $VBoxContainer / OptionButtonAnimList.get_item_text(index)

	var AnimationObj: Animation = Anim.get_animation(
		selected_anim
	)
	
	
	if AnimationObj.length >= 1.0:
		$VBoxContainer / HBoxContainer2 / LblAnimTotalTime.text = "Time: %.2fs" % [AnimationObj.length]
	else:
		$VBoxContainer / HBoxContainer2 / LblAnimTotalTime.text = "Time: %dms" % [int(AnimationObj.length * 1000)]

	
	var i: int = 0
	for track_idx in range(AnimationObj.get_track_count()):
		
		if AnimationObj.track_get_type(track_idx) == 0:
			
			var track_path: String = AnimationObj.track_get_path(track_idx)
			
			if track_path.ends_with(":frame") == true:
				$VBoxContainer / OptionButtonTracksList.add_item(
					track_path, track_idx
				)
				
				if i == 0:
					_on_OptionButtonTracksList_item_selected(i)
				i += 1

func _on_OptionButtonTracksList_item_selected(index: int) -> void :
	
	
	
	
	
	if is_valid_animplayer() == false:
		return
	
	var track_idx: int = $VBoxContainer / OptionButtonTracksList.get_item_id(index)

	var AnimationObj: Animation = Anim.get_animation(
		selected_anim
	)
	
	var track_keys_times: Array
	var track_keys_frame_numbers: Array

	
	for b in $VBoxContainer / ScrollContainer / HFlowContainerFrames.get_children():
		b.queue_free()
	
	$VBoxContainer / HBoxContainer2 / BtnCopyFramesData.disabled = true
	
	
	for track_key_idx in range(AnimationObj.track_get_key_count(track_idx)):
		
		track_keys_times.append(
			AnimationObj.track_get_key_time(track_idx, track_key_idx)
		)
		track_keys_frame_numbers.append(
			AnimationObj.track_get_key_value(track_idx, track_key_idx)
		)
		

	var i: int = 0
	for key_time in track_keys_times:
		var millis: int = 0
		
		
		if i == 0:
			
			if key_time == 0:
				
				if track_keys_times.size() > 1:
					millis = int(
						(key_time * 1000) + (track_keys_times[i + 1] * 1000)
					)
				
				else:
					millis = AnimationObj.length * 1000
			
			else:
				
				if track_keys_times.size() > 1:
					millis = int(
						(track_keys_times[i + 1] * 1000) - (key_time * 1000)
					)
				
				else:
					millis = int(
						(AnimationObj.length * 1000) - (key_time * 1000)
					)
		
		
		else:
			
			var prev_time: int = track_keys_times[i - 1] * 1000
			
			
			if prev_time == 0 and track_keys_times.size() > 2:
				millis = int(
					track_keys_times[i + 1] * 1000 - (key_time * 1000)
				)
			
			elif prev_time == 0:
				millis = int(
					(AnimationObj.length * 1000) - (key_time * 1000)
				)
			
			else:
				
				if i == track_keys_times.size() - 1:
					millis = int(
						(AnimationObj.length * 1000) - (key_time * 1000)
					)
				else:
					millis = int(
						(track_keys_times[i + 1] * 1000) - (key_time * 1000)
					)
		
		if str(millis).ends_with("9"):
			millis += 1

		
		
		var Btn = Button.new()
		Btn.text = "Frame %d : %d ms" % [track_keys_frame_numbers[i], millis]
		Btn.size_flags_horizontal = 3
		
		Btn.connect("pressed", self, "_on_BtnFrame_pressed", [millis])
		$VBoxContainer / ScrollContainer / HFlowContainerFrames.add_child(Btn)
		
		i += 1

	
	if $VBoxContainer / ScrollContainer / HFlowContainerFrames.get_child_count() > 0:
		$VBoxContainer / HBoxContainer2 / BtnCopyFramesData.disabled = false

func _on_BtnFrame_pressed(ms: int) -> void :
	OS.set_clipboard(str(ms))

func _on_BtnCopyFramesData_pressed() -> void :
	var txt: String
	
	for b in $VBoxContainer / ScrollContainer / HFlowContainerFrames.get_children():
		txt += "%s \n" % [b.text]
	OS.set_clipboard(txt)
