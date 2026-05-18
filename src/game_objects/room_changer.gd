tool 

extends Area2D

signal player_positioned

enum DIRECTION{LEFT, UP, RIGHT, DOWN}

export (DIRECTION) var direction = DIRECTION.LEFT setget _update_dir

export var identifier: String = ""
export var id_destination: String = ""
export var path_destination: String = "" setget _update_destination_path
export var size_area: int = 104 setget _update_collision_size
export var offset_area: int = 0 setget _update_collision_offset

onready var PlayerPosition = $PlayerPosition
onready var Collision = $CollisionShape2D

var Queue = preload("res://src/scripts/resource_queue.gd").new()

var _preload_started: bool

var _preload_room: bool

func _ready() -> void :
	
	
	if Engine.editor_hint == true:
		return
	
	_preload_room = Config.get_value("misc", "preload_room", false)
	
	
	if VarsGlobal.current_room_changer == identifier:
		var playable_char: = get_parent().get_node_or_null("PlayableCharacter")
		if playable_char != null:
			playable_char.global_position = PlayerPosition.global_position
			emit_signal("player_positioned")
	
func _update_destination_path(new_path) -> void :
	path_destination = new_path
	
	if ResourceLoader.exists(new_path):
		$CollisionShape2D.modulate = Color("00ff10")
	else:
		$CollisionShape2D.modulate = Color("ff0000")

func _update_collision_size(col_size: int) -> void :

	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	size_area = col_size
	$CollisionShape2D.shape.extents.y = col_size

func _update_collision_offset(col_offset: int) -> void :

	offset_area = col_offset
	$CollisionShape2D.position.y = col_offset

func _update_dir(dir) -> void :
	direction = dir
	
	scale.x = 1
	scale.y = 1
	rotation_degrees = 0
	$PlayerPosition.position = Vector2( - 16, 0)
	
	$AreaDetectPlayer / CollisionLR.disabled = true
	$AreaDetectPlayer / CollisionUD.disabled = true
	
	$AreaDetectPlayer / CollisionLR.visible = false
	$AreaDetectPlayer / CollisionUD.visible = false
	
	match direction:
		DIRECTION.UP:
			rotation_degrees = 90
			$PlayerPosition.position = Vector2( - 16 * 2, 0)
		DIRECTION.RIGHT:
			scale.x = - 1
		DIRECTION.DOWN:
			rotation_degrees = - 90
			
			
			$PlayerPosition.position = Vector2( - 16 * 3, 0)
	
	if direction in [DIRECTION.UP, DIRECTION.DOWN]:
		$AreaDetectPlayer / CollisionUD.visible = true
		$AreaDetectPlayer / CollisionUD.disabled = false
	elif direction in [DIRECTION.LEFT, DIRECTION.RIGHT]:
		$AreaDetectPlayer / CollisionLR.visible = true
		$AreaDetectPlayer / CollisionLR.disabled = false

func _on_RoomChanger_body_entered(body: Node) -> void :
	
	
	
	
	if (
		ResourceLoader.exists(path_destination) == false
		or VarsGlobal.game_data["player_hp_now"] <= 0
		or body.is_in_group("players") == false
	):
		return
	
	
	if body.has_method("set_enabled_input"):
		body.set_enabled_input(false)
	
	
	if body.has_method("invencibility"):
		body.invencibility(0.5, false)
	
	VarsGlobal.current_room_changer = id_destination
	
	
	VarsGlobal.game_data["player_facing"] = VarsGlobal.Player.facing
	
	if _preload_started == false or _preload_room == false:
		SceneChanger.change_scene(path_destination)
	elif Queue.is_ready(path_destination) == false:
		Queue.cancel_resource(path_destination)
		
	else:
		SceneChanger.change_scene_to(Queue.get_resource(path_destination))

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	if (
		ResourceLoader.exists(path_destination) == true
		and _preload_room == true
	):
		_preload_started = true
		Queue.start()
		Queue.queue_resource(path_destination)

func _on_AreaDetectPlayer_area_exited(_area: Area2D) -> void :
	
	pass
