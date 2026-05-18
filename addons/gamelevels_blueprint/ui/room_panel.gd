tool 

extends GraphNode

signal edit_request(room_panel_node)

var scene_type: int = 0
var file_path: String
var description: String
var color_panel: Color

var icons: Dictionary

func _enter_tree() -> void :
	
	if is_connected("raise_request", get_dock(), "_on_RoomPanel_raise_request") == false:
		connect("raise_request", get_dock(), "_on_RoomPanel_raise_request", [name])
	if is_connected("focus_entered", self, "_on_RoomPanel_focus_entered") == false:
		connect("focus_entered", self, "_on_RoomPanel_focus_entered")
	if is_connected("focus_exited", self, "_on_RoomPanel_focus_exited") == false:
		connect("focus_exited", self, "_on_RoomPanel_focus_exited")

	update_data()

func get_dock() -> Object:
	return get_parent().get_parent()

func get_name() -> String:
	return file_path.get_file().replace(".tscn", "")

func get_center_offset() -> Vector2:
	return offset + (rect_size / 2)

func set_visible_action_buttons(val: bool) -> void :
	$VBoxContainer / HBoxContainer.visible = val

func update_data() -> void :
	
	var file: = File.new()
	
	if file_path.empty():
		return
	
	
	$VBoxContainer / HBoxContainer / BtnGoTo.hint_tooltip = "Go to: " + file_path
	
	
	$VBoxContainer / Label.text = get_name()
	
	
	
	if file.file_exists(file_path) == false:
		$VBoxContainer / Label.text = "(!) " + $VBoxContainer / Label.text
		$VBoxContainer / HBoxContainer / BtnGoTo.disabled = true
		$VBoxContainer / HBoxContainer / BtnPlay.disabled = true
		$VBoxContainer / HBoxContainer / BtnCopyPath.disabled = true
	
	
	else:
		$VBoxContainer / HBoxContainer / BtnGoTo.disabled = false
		$VBoxContainer / HBoxContainer / BtnPlay.disabled = false
		$VBoxContainer / HBoxContainer / BtnCopyPath.disabled = false
	
		
		var resource = ResourceLoader.load(file_path)
		if resource is PackedScene:
			var instance = resource.instance()
			if instance is Spatial:
					scene_type = 1

	_set_panel_color(color_panel)
	
	
	hint_tooltip = description
	
	
	var icons_keys: Array = icons.keys()
	var icons_visible_count: int = 0
	for icn_check in get_node("%HBxTopIcons").get_children():
		if icons_keys.has(icn_check.name):
			icn_check.visible = icons[icn_check.name]
			if icn_check.visible == true:
				icons_visible_count += 1
		else:
			icn_check.visible = false

	if icons_visible_count > 0:
		get_node("%TopPanelIcons").visible = true
	else:
		get_node("%TopPanelIcons").visible = false

func _set_panel_color(clr: Color) -> void :
	var duplicate_style = get_stylebox("frame").duplicate()
	duplicate_style.bg_color = clr
	add_stylebox_override("frame", duplicate_style)
	
	duplicate_style = get_stylebox("selectedframe").duplicate()
	duplicate_style.bg_color = clr
	add_stylebox_override("selectedframe", duplicate_style)
	
	
	duplicate_style = get_node("%TopPanelIcons").get_stylebox("panel").duplicate()
	duplicate_style.bg_color = clr
	get_node("%TopPanelIcons").add_stylebox_override("panel", duplicate_style)

func _on_BtnGoTo_pressed() -> void :
	get_dock().open_scene(file_path, scene_type)

func _on_BtnPlay_pressed() -> void :
	get_dock().play_scene(file_path)

func _on_RoomPanel_focus_entered() -> void :
	if description.empty() == false:
		get_dock().show_notif(description)

func _on_RoomPanel_focus_exited() -> void :
	get_dock().hide_notif()
	

func _on_BtnCopyPath_pressed() -> void :
	OS.set_clipboard(file_path)
	

func _on_BtnEdit_pressed() -> void :
	emit_signal("edit_request", self)
