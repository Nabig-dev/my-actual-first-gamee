extends Node2D

var node_emitter = null

var node_target = null

func _ready() -> void :
	$AnimationPlayer.play("show")
	
	if node_emitter != null and node_emitter.has_signal("floor_exited"):
		node_emitter.connect("floor_exited", self, "_on_target_floor_exited")

func _physics_process(_delta: float) -> void :
	if node_target != null:
		global_position = node_target.global_position

func _on_target_floor_exited() -> void :
	node_target = null
