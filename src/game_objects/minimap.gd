extends Node2D


var ColorFlatShader = preload("res://src/gdshaders/flat_color.gdshader")
onready var Node2DMap = get_node("%NodeMap")
onready var Cam = $Camera

func _ready() -> void :
	load_map_stage()






func load_map_stage(nocache: bool = false) -> void :
	
	for n in Node2DMap.get_children():
		
		if n is Node2D == true:
			n.queue_free()
	
	var map_path: String = "res://stages/%s/map.tscn" % [
		VarsGlobal.selected_stage
	]
	if ResourceLoader.exists(map_path):
		var MapInstance = ResourceLoader.load(map_path, "", nocache).instance()
		Node2DMap.add_child(MapInstance)
		yield(get_tree(), "idle_frame")
		Node2DMap.set_initial_data()


func refresh_minimap_limits() -> void :
	
	
	if VarsGlobal.GameScenario != null:
		Cam.limit_left = VarsGlobal.GameScenario.CameraNode.get_limit(0)
		Cam.limit_top = VarsGlobal.GameScenario.CameraNode.get_limit(1)
		Cam.limit_right = VarsGlobal.GameScenario.CameraNode.get_limit(2)
		Cam.limit_bottom = VarsGlobal.GameScenario.CameraNode.get_limit(3)



func add_object(_obj: Object, _colour: Color) -> void :















	pass

func _apply_shader(obj: Object, colour: Color) -> void :
	obj.material = ShaderMaterial.new()
	obj.material.shader = ColorFlatShader
	obj.material.set_shader_param("active", true)
	obj.material.set_shader_param("colour", colour)


func _on_Timer_timeout() -> void :
	var GridWin = VarsGlobal.GameScenario.get_node_or_null(
		"CameraLimit/GridWindowSize"
	)
	if GridWin != null:
		GridWin.connect(
			"current_pos_updated", self, 
			"_on_current_pos_updated"
		)
	Node2DMap.center()

func _on_current_pos_updated() -> void :
	Node2DMap.center()
