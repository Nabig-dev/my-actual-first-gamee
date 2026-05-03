extends Node

signal command_executed(command_name)


var _commands_list: = [
	["hadouken", "down_left_whip"], 
	["hadouken", "down_right_whip"], 
	["whip_h", "up_left_down_whip"], 
	["whip_h", "up_right_down_whip"], 
	["whip_spin", "left_left_whip"], 
	["whip_spin", "right_right_whip"], 
	["k_code", "up_up_down_down_left_right_left_right_whip"]
	
]

var command_executing: bool



var _commands: String



onready var TimerPressed = $Timer

func _physics_process(_delta: float) -> void :
	
	if Input.is_action_just_pressed("ui_up"):
		_add_command("up")
	if Input.is_action_just_pressed("ui_down"):
		_add_command("down")
	if Input.is_action_just_pressed("ui_left"):
		_add_command("left")
	if Input.is_action_just_pressed("ui_right"):
		_add_command("right")

	if Input.is_action_just_pressed("attack"):
		_add_command("whip")


	
	if Input.is_action_just_pressed("jump"):
		_add_command("jump")

func _add_command(new_command: String) -> void :
	
	if TimerPressed.is_stopped():
		_commands = new_command
	
	else:
		_commands = "%s_%s" % [_commands, new_command]
		
		for c in _commands_list:
			if _commands.ends_with(c[1]):
				command_executing = true
				
				emit_signal("command_executed", c[0])
				
				_commands = ""
				command_executing = false
	
	TimerPressed.start()
