tool 

extends Node2D

signal closed

export var active: bool = true
export var scale_x: int = 1 setget _update_scalex
export var spawn_position_name: String

export var color_inactive: Color = Color("ff0000")

func _ready() -> void :
	if Engine.is_editor_hint() == false:
		$AnimationPlayer.play("idle")
		refresh_modulate()

func refresh_modulate() -> void :
	if Engine.is_editor_hint() == false:
		if active == false:
			$DoorInterior.self_modulate = color_inactive
		else:
			$DoorInterior.self_modulate = Color.white

func _update_scalex(scalex: int) -> void :
	scale_x = scalex
	$DoorInterior.scale.x = scale_x

func _on_Area2D_area_entered(_area: Area2D) -> void :
	
	if Engine.is_editor_hint() == true or active == false or VarsGlobal.current_building_door != "":
		return
	
	
	if $Timer.get_time_left() > 0.5:
		
		$AnimationPlayer.play("opened")
		VarsGlobal.Player.set_enabled_input(false)
		
		yield(get_tree().create_timer(0.5), "timeout")
		
		$AnimationPlayer.play("close")
		
		VarsGlobal.Player.move(Vector2(scale_x * 1, 0))
		yield(get_tree().create_timer(0.3), "timeout")
		VarsGlobal.Player.stop_move()
		
		yield($AnimationPlayer, "animation_finished")
		
		Audio.play_sfx("door_simple_close_short")
		
		VarsGlobal.Player.set_enabled_input(true)
		
		$AnimationPlayer.play("idle")
		
		emit_signal("closed")
	
	else:
		$Timer2.start()
		VarsGlobal.current_building_door = spawn_position_name
		VarsGlobal.Player.set_enabled_input(false)
		Audio.play_sfx("door_simple_open")
		$AnimationPlayer.play("open")
		yield($AnimationPlayer, "animation_finished")
		VarsGlobal.Player.move(Vector2(scale_x * - 1, 0))
		Audio.play_sfx("door_simple_close")
	

func _on_Timer2_timeout() -> void :
	VarsGlobal.Player.set_enabled_input(true)
