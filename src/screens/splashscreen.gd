extends Control

onready var Anim = $AnimationPlayer

func _ready() -> void :
	Anim.play("danny")

func _process(_delta: float) -> void :
	if Input.is_action_just_pressed("ui_accept"):
		_on_AnimationPlayer_animation_finished(Anim.current_animation)
	elif Input.is_action_just_pressed("ui_start"):
		_on_AnimationPlayer_animation_finished("godot")

func play_snd(audio: String) -> void :
	Audio.play_sfx(audio)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void :
	match anim_name:
		"danny":
			Anim.play("godot")
		"godot":
			
			if (
				Config.get_value("misc", "firstrun", false) == false
				and Features.has("pc") == true
				and Features.has("xbox") == false
				and Features.has("ps") == false
				and Features.has("switch") == false
				and (
					Steam.is_init() == false
					or (
						Steam.is_init() == true
						and Steam.utils.is_running_on_steam_deck() == false
					)
				)
			):
				SceneChanger.change_scene("res://src/screens/initial_pc_config_wizard.tscn")
			
			elif (
				Config.get_value("misc", "controller_mapped_first_time", false) == false
				and Features.has("mobile") == true
				and Gamepad.is_controller_connected() == true
				and Config.get_value("misc", "firstrun", false) == false
			):
				SceneChanger.change_scene("res://src/game_objects/first_run_map_control.tscn")
			
			else:
				Config.set_value("misc", "firstrun", true)
				Config.set_value("misc", "controller_mapped_first_time", true)
				SceneChanger.change_scene("res://src/screens/title_screen.tscn")
