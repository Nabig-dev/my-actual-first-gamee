tool 
class_name Behavior
extends Resource




















var owner: Node = null setget set_owner, get_owner


var enabled: bool = true setget set_enabled, get_enabled


func _awake() -> void :
	pass



func _on_enable() -> void :
	pass



func _on_disable() -> void :
	pass



func get_behavior(p_type: Script) -> Resource:
	return owner.get_element(p_type)


func set_enabled(p_enable: bool) -> void :
	if enabled == p_enable:
		return
	enabled = p_enable
	if p_enable:
		_on_enable()
		owner._add_to_callbacks()
	else:
		_on_disable()
		owner._remove_from_callbacks()


func get_enabled() -> bool:
	return enabled


func set_owner(p_owner: Node) -> void :
	assert (p_owner)
	owner = p_owner


func get_owner() -> Node:
	return owner




static func is_abstract() -> bool:
	return true
