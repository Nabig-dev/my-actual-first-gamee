extends Control

func _ready() -> void :
	
	var Tw: = create_tween()
	
	Tw.tween_property($Label, "modulate", Color.white, 3)
	yield(Tw, "finished")
	yield(get_tree().create_timer(1), "timeout")
	Tw = create_tween()
	Tw.tween_property($Label, "modulate", Color("00ffffff"), 2)
	yield(Tw, "finished")
	
	Audio.stop_music()
	
	$Label2.visible = true
	get_node("%HBxSkip").visible = true
	$VideoPlayer.play()

func _process(_delta: float) -> void :
	if Input.is_action_just_pressed("ui_start"):
		if get_node("%HBxSkip").visible == true:
			_on_video_end()

func _on_video_end() -> void :
	SceneChanger.change_scene("res://src/screens/splashscreen.tscn")
