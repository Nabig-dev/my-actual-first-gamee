extends CanvasLayer

signal closed

export var NodeMap: NodePath
export var ButtonsNode: NodePath

var CurrentStationButton: Control

var _traveling: bool

func _ready() -> void :
	
	visible = false
	$TextureBG.visible = false
	
	if NodeMap.is_empty() == false:
		get_node(NodeMap).set_initial_data()
	
	if ButtonsNode.is_empty() == false:
		
		for n in get_node(ButtonsNode).get_children():
			if n is TextureButton:
				n.connect(
					"focus_entered", self, 
					"_on_focus_button", 
					[n]
				)

func _process(_delta: float) -> void :
	
	if visible == false or _traveling == true:
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		go_to()
	elif Input.is_action_just_pressed("ui_cancel"):
		close()

func go_to() -> void :
	
	if CurrentStationButton == null or _traveling == true:
		return

	if CurrentStationButton.is_in_group("map_full_button"):
		
		if (
			CurrentStationButton.scene_path != get_tree().current_scene.filename
			and _traveling == false
		):
			_traveling = true
			Audio.stop_music()
			Audio.play_sfx("train_start")
			$TextureBG / AnimPlayer.play("black")
			yield($TextureBG / AnimPlayer, "animation_finished")
			yield(get_tree().create_timer(4), "timeout")
			Audio.play_sfx("train_end")
			yield(get_tree().create_timer(2), "timeout")
			VarsGlobal.current_room_changer = ""
			VarsGlobal.current_building_door = ""
			VarsGlobal.game_data.current_room_changer = ""
			VarsGlobal.game_data.current_building_door = ""
			SceneChanger.change_scene(
				CurrentStationButton.scene_path
			)
		else:
			Audio.play_sfx("ui_incorrect")

func open() -> void :
	if _traveling == true:
		return
	for btn in get_node(ButtonsNode).get_children():
		if btn.scene_path == get_tree().current_scene.filename:
			btn.grab_focus()
		
		var btn_filename: String = btn.scene_path.get_file().replace(".tscn", "")
		if VarsGlobal.game_data["visited_rooms"].has(btn_filename) == false:
			btn.visible = false
		
	Audio.play_sfx("paper_get")
	visible = true
	$TextureBG.visible = true

func close() -> void :
	if _traveling == true:
		return
	Audio.play_sfx("ui_cancel")
	$TextureBG.visible = false
	yield(get_tree().create_timer(0.2), "timeout")
	visible = false
	emit_signal("closed")

func _on_focus_button(whatbtn: Control) -> void :
	if _traveling == true:
		return
	Audio.play_sfx("ui_btn_focused")
	CurrentStationButton = whatbtn
