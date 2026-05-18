extends Control

var BtnImg = preload("res://src/ui_elements/gallery_img_button.tscn")
onready var NodeTabContainer = $MarginContainer / VBoxContainer / TabContainer
var _can_change_tabs: bool = true
var _tabs_nodes: Array
var _btnimg_focused: TextureButton = null
var _btngrid_childrens: Array
var _btnimg_idx_current: int

func _ready() -> void :
	
	get_node("%ClrRectLoading").visible = true
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	
	if Features.has("mobile") == false:
		get_node("%BtnCloseFullView").disconnect("pressed", self, "_on_BtnCloseFullView_pressed")
	
	_tabs_nodes = NodeTabContainer.get_children()
	get_node("%ImageFull").visible = false
	var fanarts: Dictionary = load_textures("res://art_gallery/fanarts/")
	var official: Dictionary = load_textures("res://art_gallery/official/")
	var i: int
	
	i = 0
	for fn in fanarts:
		var ObjInstance = BtnImg.instance()
		ObjInstance.name = fn
		ObjInstance.set_texture(fanarts[fn])
		ObjInstance.node_idx = i
		ObjInstance.connect(
			"selected", self, "_on_BtnImg_pressed"
		)
		ObjInstance.connect(
			"focus_entered", self, "_on_BtnImg_focused", [ObjInstance]
		)
		
		get_node(
			"MarginContainer/VBoxContainer/TabContainer/FANARTS/ScrollContainer/Grid"
		).add_child(ObjInstance)
		i += 1

	i = 0
	for of in official:
		var ObjInstance = BtnImg.instance()
		ObjInstance.name = of
		ObjInstance.set_texture(official[of])
		ObjInstance.node_idx = i
		ObjInstance.connect(
			"selected", self, "_on_BtnImg_pressed"
		)
		ObjInstance.connect(
			"focus_entered", self, "_on_BtnImg_focused", [ObjInstance]
		)
		
		get_node(
			"MarginContainer/VBoxContainer/TabContainer/OFFICIAL/ScrollContainer/Grid"
		).add_child(ObjInstance)
		i += 1

	focus_btnimg()
	
	get_node("%ClrRectLoading").visible = false

func _process(_delta: float) -> void :
	
	if _can_change_tabs and Input.is_action_just_pressed("ui_cancel"):
		_on_BtnReturn_pressed()
	
	if _can_change_tabs and Input.is_action_just_pressed("ui_focus_prev"):
		_select_new_tab("prev")
		
	if _can_change_tabs and Input.is_action_just_pressed("ui_focus_next"):
		_select_new_tab("next")

	
	if _can_change_tabs == false:
		if Input.is_action_just_pressed("ui_cancel"):
			_on_BtnCloseFullView_pressed()
		elif Input.is_action_just_pressed("ui_left"):
			_select_new_img("prev")
		elif Input.is_action_just_pressed("ui_right"):
			_select_new_img("next")
		elif (
			get_node("%BtnRotateImage").visible == true
			and Input.is_action_just_pressed("ui_select")
		):
			_on_BtnRotateImage_pressed()
		

func load_textures(path: String) -> Dictionary:
	
	var files_dict: Dictionary
	for f in FuncsFiles.get_files(path):
		f = f.replace(".import", "")
		if f.ends_with(".jpg") or f.ends_with(".png"):
			files_dict[
				f.split(".")[0]
			] = load(path + f)
	return files_dict

func focus_btnimg() -> void :
	if _btnimg_focused != null:
		_btnimg_focused.grab_focus()
	
	else:
		_btngrid_childrens = NodeTabContainer.get_tab_control(
			NodeTabContainer.current_tab
		).get_node("ScrollContainer/Grid").get_children()
		_btngrid_childrens[0].grab_focus()
	_can_change_tabs = true

func _select_new_img(direction: String) -> void :
	_btnimg_idx_current = FuncsArrays.get_new_position_on_array(
		_btngrid_childrens, _btnimg_idx_current, direction
	)
	
	_on_BtnImg_pressed(
		_btngrid_childrens[_btnimg_idx_current].name, 
		_btngrid_childrens[_btnimg_idx_current].texture_normal, 
		false
	)
	_btnimg_focused = _btngrid_childrens[_btnimg_idx_current]

func _select_new_tab(direction: String) -> void :
	var new_tab: int = FuncsArrays.get_new_position_on_array(
		_tabs_nodes, NodeTabContainer.current_tab, direction
	)
	NodeTabContainer.current_tab = new_tab

func _on_BtnImg_focused(nodeimg: TextureButton) -> void :
	_btnimg_focused = nodeimg
	_btnimg_idx_current = nodeimg.node_idx

func _on_BtnImg_pressed(filename: String, textur: Texture, snd: bool = true) -> void :
	if snd == true:
		Audio.play_sfx("ui_accept")
	var texture_size = textur.get_size()
	_can_change_tabs = false
	
	
	
	if (
		texture_size.y > texture_size.x
		and (
			Features.has("mobile") == true
			or (Steam.is_init() and Steam.utils.is_running_on_steam_deck())
		)
	):
		get_node("%BtnRotateImage").visible = true
	else:
		get_node("%BtnRotateImage").visible = false
	
	get_node("%ImageTextureFull").visible = true
	get_node("%RectCtrlFullRotated").visible = false
	get_node("%ImageTextureFull").texture = textur
	get_node("%ImageTextureFullRotated").texture = textur
	get_node("%LblImageName").text = filename
	get_node("%ImageFull").visible = true
	get_node("%BtnCloseFullView").grab_focus()
	release_focus()

func _on_BtnCloseFullView_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	get_node("%ImageFull").visible = false
	focus_btnimg()

func _on_BtnReturn_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	SceneChanger.change_scene("res://src/screens/main_menu.tscn")

func _on_BtnRotateImage_pressed() -> void :
	
	if get_node("%ImageTextureFull").visible == true:
		get_node("%ImageTextureFull").visible = false
		get_node("%RectCtrlFullRotated").visible = true
	else:
		get_node("%ImageTextureFull").visible = true
		get_node("%RectCtrlFullRotated").visible = false

func _on_TabContainer_tab_changed(_tab: int) -> void :
	_btnimg_focused = null
	focus_btnimg()
	Audio.play_sfx("ui_big_btn_focused")
