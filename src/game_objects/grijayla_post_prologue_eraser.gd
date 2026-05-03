extends Node

export (Array, NodePath) var nodes_delete: Array


func _ready() -> void :
	if VarsGlobal.has_flag("prologue_finished") == false:
		return
	yield(get_tree(), "idle_frame")
	for n_path in nodes_delete:
		var node_obj: = get_node_or_null(n_path)
		if node_obj != null and is_instance_valid(node_obj):
			node_obj.queue_free()
