tool 
class_name DebugLabel
extends Label















enum UpdateMode{
	IDLE, 
	PHYSICS, 
	MANUAL, 
}

export (UpdateMode) var update_mode = UpdateMode.IDLE setget set_update_mode

export var update_debug_info: bool = true


export var target_path: = NodePath() setget set_target_path

export var show_label_name: = false
export var show_target_name: = false





export var properties: = PoolStringArray()


var target: Object

func _init(p_target: Object = null) -> void :
	if p_target != null:
		target = p_target







func _enter_tree() -> void :
	set_process_internal(true)

	if not OS.is_debug_build():
		text = ""
		hide()
		return
	if target == null:
		if not target_path.is_empty():
			_update_target_from_path()
		else:
			target = get_parent()


func _exit_tree() -> void :
	set_process_internal(false)
	set_physics_process_internal(false)

	target = null


func _notification(what: int) -> void :
	if update_debug_info == false:
		return
	
	
	match what:
		NOTIFICATION_INTERNAL_PROCESS:
			_update_debug_info()
		NOTIFICATION_INTERNAL_PHYSICS_PROCESS:
			_update_debug_info()


func set_target_path(p_path: NodePath) -> void :
	target_path = p_path
	call_deferred("_update_target_from_path")


func set_update_mode(p_mode: int) -> void :
	update_mode = p_mode

	match update_mode:
		UpdateMode.IDLE:
			set_process_internal(true)
			set_physics_process_internal(false)
		UpdateMode.PHYSICS:
			set_process_internal(false)
			set_physics_process_internal(true)
		UpdateMode.MANUAL:
			set_process_internal(false)
			set_physics_process_internal(false)


func watch(p_what: String) -> void :
	properties = PoolStringArray([p_what])


func watchv(p_what: PoolStringArray) -> void :
	properties = p_what


func watch_append(p_what: String) -> void :
	properties.append(p_what)


func watch_appendv(p_what: PoolStringArray) -> void :
	properties.append_array(p_what)


func clear() -> void :
	properties = PoolStringArray()


func update() -> void :
	
	_update_debug_info()
	.update()


func _update_debug_info() -> void :
	if not OS.is_debug_build() or update_debug_info == false:
		return

	text = ""

	if not is_instance_valid(target):
		text = "null"
		return

	if show_label_name:
		text += "%s\n" % [name]

	if show_target_name:
		var object_name: = String()

		if target is Node:
			object_name = target.name
		elif target is Resource:
			object_name = target.resource_name

		if not object_name.empty():
			text += "%s\n" % [object_name]

	for prop in properties:
		if prop.empty():
			continue
		var var_str = var2str(target.get_indexed(prop))
		text += "%s = %s\n" % [prop, var_str]


func _update_target_from_path() -> void :
	if has_node(target_path):
		target = get_node(target_path)
	
