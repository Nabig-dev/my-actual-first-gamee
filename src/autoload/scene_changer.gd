extends Node

signal scene_changed

var previous_scene_filename: String = ""
var current_scene_filename: String = ""

var changing_scene: bool = false
var err: int

onready var AnimPlayer = $AnimationPlayer


func change_scene(path) -> bool:
	
	if ResourceLoader.exists(path):
		
		changing_scene = true
		
		yield(get_tree().create_timer(0.1), "timeout")
		
		
		AnimPlayer.play("fade")
		yield(AnimPlayer, "animation_finished")
		
		
		previous_scene_filename = get_tree().current_scene.filename.get_file()
		
		
		err = get_tree().change_scene(path)
		
		
		AnimPlayer.play_backwards("fade")
		yield(AnimPlayer, "animation_finished")
		
		changing_scene = false
		
		emit_signal("scene_changed")
		return true
	
	else:
		print_debug("Failed to change scene, %s doesn't exists." % [path])
		return false

func change_scene_to(scene: PackedScene) -> bool:
	
	changing_scene = true
	yield(get_tree().create_timer(0.1), "timeout")
	AnimPlayer.play("fade")
	yield(AnimPlayer, "animation_finished")
	previous_scene_filename = get_tree().current_scene.filename.get_file()
	
	
	err = get_tree().change_scene_to(scene)
	

	
	AnimPlayer.play_backwards("fade")
	yield(AnimPlayer, "animation_finished")
	
	changing_scene = false
	
	emit_signal("scene_changed")
	return true
