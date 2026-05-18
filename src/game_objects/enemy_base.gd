extends Node

signal enemy_defeated(NodeEnemy)
signal state_changed(state)


export var node_facing: NodePath


export var anim_player: NodePath


export var auto_dead_state: bool = true

export var hurtbox: NodePath

export var auto_facing_on_ready: bool = true

var state: String = "idle"
var prev_state: String = "idle"

var facing: int = 1

var NodeParent: Object = null
var NodeFacing: Object = null
var AnimPlayer: Object = null


var _is_animation_tree: bool = false

var _anim_state_machine: AnimationNodeStateMachinePlayback

onready var TimerFacingTo = $TimerFacingTo
onready var TimerChangeDirCoolDown = $TimerChangeDirCoolDown

func _ready() -> void :
	
	NodeParent = get_parent()
	
	if NodeParent.is_in_group("enemies") == false:
		NodeParent.add_to_group("enemies")
	
	
	
	if node_facing.is_empty() == false:
		NodeFacing = get_node(node_facing)
	
	
	if anim_player.is_empty() == false:
		AnimPlayer = get_node(anim_player)
		
		if AnimPlayer is AnimationTree:
			_is_animation_tree = true
			_anim_state_machine = AnimPlayer.get("parameters/playback")

	
	if auto_dead_state == true and hurtbox.is_empty() == false:
		
		get_node(hurtbox).connect("defeated", self, "_on_death")
	
	
	yield(TimerFacingTo, "timeout")
	if auto_facing_on_ready == true:
		change_direction("to_player")


func change_state(
	new_state: String, forced: bool = false, anim_travel: bool = false
) -> void :
	if (new_state != state or forced == true) and state != "dead":
		
		prev_state = state
		state = new_state
		
		
		if AnimPlayer == null:
			return
		
		
		if _is_animation_tree == false and AnimPlayer.has_animation(state) == true:
			AnimPlayer.play(state)
			emit_signal("state_changed", state)
			return
		
		
		
		if anim_travel == true:
			_anim_state_machine.travel(state)
		else:
			_anim_state_machine.start(state)
		
		emit_signal("state_changed", state)




func change_direction(opt: String = "inverse") -> void :
	
	
	if TimerChangeDirCoolDown.is_inside_tree() == false:
		return
	
	if state == "dead":
		return
		
	match opt:
		
		"to_player":
			if TimerChangeDirCoolDown.is_stopped() == true:
				TimerChangeDirCoolDown.start()
				
				facing = VarsGlobal.GameScenario.get_facing_pointing_to(
					NodeParent, VarsGlobal.Player
				)
				
				
				facing = facing * - 1
		
		"inverse":
			if TimerChangeDirCoolDown.is_stopped() == true:
				TimerChangeDirCoolDown.start()
				facing = facing * - 1
		
		"-1", "1":
			facing = int(opt)

	
	if "direction" in NodeParent:
		NodeParent.direction.x = facing
	
	
	if NodeFacing != null:
		NodeFacing.scale.x = abs(NodeFacing.scale.x) * facing

func get_player_position(add_offset: Vector2 = Vector2.ZERO) -> Vector2:
	return VarsGlobal.Player.global_position + add_offset

func get_player_distance() -> float:
	return NodeParent.global_position.distance_to(VarsGlobal.Player.global_position)


func is_player_up() -> bool:
	if VarsGlobal.Player.global_position.y < NodeParent.global_position.y:
		return true
	else:
		return false

func _on_death() -> void :
	emit_signal("enemy_defeated", NodeParent)
	if NodeParent.is_in_group("enemies") == true:
		NodeParent.remove_from_group("enemies")
	change_state("dead", true, false)
