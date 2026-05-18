extends CanvasLayer

var CRTShaderMaterial = preload("res://assets/tres/crt_shader_material.tres")

var vhs_add: bool = false

onready var ClrRect = $ColorRect

func _ready() -> void :
	
	
	
	if Features.has("debug") == true or Features.has("mobile") == true:
		get_node("Control").visible = false

	
	get_tree().get_root().connect("size_changed", self, "_on_MainViewport_size_changed")
	
	Config.connect("value_changed", self, "_on_config_changed")

	_on_MainViewport_size_changed()

func _on_config_changed(section: String, key: String, _value) -> void :
	if section == "video" and key == "filter":
		_on_MainViewport_size_changed()

func _on_MainViewport_size_changed() -> void :
	
	
	var filter: String = Config.get_value("video", "filter", "none")

	vhs_add = false

	if filter == "none":
		ClrRect.material = null
		ClrRect.visible = false

	elif filter.begins_with("crt_"):

		var new_size: Vector2 = get_tree().get_root().size
		ClrRect.visible = true
		ClrRect.material = CRTShaderMaterial
		ClrRect.material.set_shader_param("screen_size", new_size)

		match filter:
			"crt_curved":
				vhs_add = true
				ClrRect.material.set_shader_param("show_curvature", false)
				ClrRect.material.set_shader_param("show_vignette", true)
				ClrRect.material.set_shader_param("show_horizontal_scan_lines", false)
				ClrRect.material.set_shader_param("show_vertical_scan_lines", false)
			"crt_no_curve":
				ClrRect.material.set_shader_param("show_curvature", false)
				ClrRect.material.set_shader_param("show_vignette", false)
				ClrRect.material.set_shader_param("show_horizontal_scan_lines", true)
				ClrRect.material.set_shader_param("show_vertical_scan_lines", true)
			"crt_simple":
				ClrRect.material.set_shader_param("show_curvature", false)
				ClrRect.material.set_shader_param("show_vignette", false)
				ClrRect.material.set_shader_param("show_horizontal_scan_lines", false)
				ClrRect.material.set_shader_param("show_vertical_scan_lines", false)
