extends Control






var data_ini_path: String = "res://stages/%s/data.json" % [
	VarsGlobal.selected_stage
]
var DataConf = preload("res://addons/json_config_file/json_conf.gd").new()


var _slot_to_load: int
var _slot_to_restore: int
var _snapshot_game_data_to_load: Dictionary

func _notification(what: int) -> void :
	if what == NOTIFICATION_EXIT_TREE:
		DataConf.queue_free()

func _ready() -> void :
	
	
	Audio.play_music("crimson_moon", "high", 2)
	
	focus_first_savegame()
	
	for b in get_node("%KeyboardGridContainer").get_children():
		b.connect("pressed", self, "_on_BtnLetter_pressed", [b.get_node("Label").text])

	
	get_node("%BtnDeleteSlot0").disabled = not Savedata.game_exists(0, VarsGlobal.selected_stage, false)
	get_node("%BtnDeleteSlot1").disabled = not Savedata.game_exists(1, VarsGlobal.selected_stage, false)
	get_node("%BtnDeleteSlot2").disabled = not Savedata.game_exists(2, VarsGlobal.selected_stage, false)
	
	
	if DataConf.load_file(data_ini_path) == OK:
		get_node("%LblStageTitle").text = "- %s -" % [
			tr(DataConf.get_value("info", "title", ""))
		]
	else:
		get_node("%LblStageTitle").visible = false
	
	
	get_node("%BtnRestoreData").visible = false
	
	
	
	
	if OS.get_name() == "Android" or Features.has("demo") == false:
		GooglePlayGamesServices.connect("sign_in_user_authenticated", self, "_on_playstore_signin")
		GooglePlayGamesServices.connect("snapshots_game_loaded", self, "_on_playstore_snapshots_game_loaded")
		GooglePlayGamesServices.sign_in_is_authenticated()

func _process(_delta: float) -> void :
	
	if get_node("%PopupKeyboard").visible == true and get_node("%PopupDifficulty").visible == false:
		
		if Input.is_action_just_pressed("ui_start"):
			_on_BtnCreatedSaveName_pressed()
		
		if Input.is_action_just_pressed("ui_select"):
			_on_BtnCancelSaveName_pressed()
		
		if Input.is_action_just_pressed("ui_cancel"):
			_on_BtnEraseLetter_pressed()
	
	if get_node("%PopupDifficulty").visible == true:
		if Input.is_action_just_pressed("ui_accept"):
			if get_node("%BtnDiffSelected").disabled == false:
				_on_BtnDiffSelected_pressed()
			else:
				Audio.play_sfx("ui_incorrect")

func focus_first_savegame() -> void :
	
	get_node("%BtnSave0").grab_focus()

func go_to_scene(scene_path: String) -> void :
	
	Audio.stop_music()
	
	get_node("%PopupKeyboard").hide()
	get_node("%PopupQuicksaveExists").hide()
	get_node("%PopupDeleteData").hide()
	
	Audio.play_sfx("cinematic_hit")
	get_node("%ControlGameLoaded").grab_focus()
	set_process(false)
	get_node("%PreGoToSceneAnim").play("show")
	get_node("%TimerGoToScene").start()
	
	if Features.has("editor") == false:
		yield(get_node("%TimerGoToScene"), "timeout")
	
	SceneChanger.change_scene(scene_path)

func load_game(quick: bool = false) -> void :
	Audio.play_sfx("ui_accept")
	VarsGlobal.reset_data()
	var err = Savedata.load_game(
		VarsGlobal.selected_slot, 
		VarsGlobal.selected_stage, 
		quick
	)
	
	if err == OK:
		
		
		VarsGlobal.current_room_changer = ""
		
		Audio.stop_music()
		
		
		erase_quicksave()
		
		
		go_to_scene(VarsGlobal.game_data["current_room_path"])

	elif err == ERR_INVALID_PARAMETER:
		Notification.show_notif("Beta/Release savefiles are incompatible.")
	else:
		Notification.show_notif("Error Loading: " + str(err))

func erase_quicksave():
	
	if Savedata.game_exists(
			VarsGlobal.selected_slot, 
			VarsGlobal.selected_stage, 
			true
	):
		var err_del = Savedata.delete_game(
			VarsGlobal.selected_slot, 
			VarsGlobal.selected_stage, 
			true
		)
		if err_del != OK:
			Notification.show_notif("Error deleting savegame " + str(err_del))

func _set_disabled_snapshot_btns(disable: bool) -> void :
	get_node("%SpinBoxSlotSnapshotLoad").set_disabled(disable)
	get_node("%SpinBoxSlotSnapshotSave").set_disabled(disable)
	
	get_node("%BtnStartRestoreSnapshot").disabled = disable


func _on_EraseGameData(slot: int) -> void :
	Audio.play_sfx("ui_success")
	var err = Savedata.delete_game(
		slot, 
		VarsGlobal.selected_stage, 
		false
	)
	
	if err == OK:
		
		if Savedata.game_exists(slot, VarsGlobal.selected_stage, true) == true:
			
			Savedata.delete_game(
				slot, 
				VarsGlobal.selected_stage, 
				true
			)
		Notification.show_notif(tr("DATA_ERASE") + " (slot: %d)" % [slot + 1])
		
		
		get_tree().reload_current_scene()
	else:
		Notification.show_notif("Error with delete: " + str(err))

func _on_BtnReturn_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	SceneChanger.change_scene("res://src/screens/main_menu.tscn")

func _on_LoadSaveGame(slot: int) -> void :
	Audio.play_sfx("ui_accept")
	var BtnSave = get_node("%BtnSave" + str(slot))
	VarsGlobal.selected_slot = slot
	
	if BtnSave.empty_slot == true:
		get_node("%LblSaveNameTitle").text = ""
		get_node("%KeyboardGridContainer").get_children()[0].grab_focus()
		get_node("%PopupKeyboard").show()
	
	else:
		
		if Savedata.game_exists(
				VarsGlobal.selected_slot, 
				VarsGlobal.selected_stage, 
				true
		):
			get_node("%PopupQuicksaveExists").show()
			get_node("%BtnQuickLoad").grab_focus()
		else:
			
			load_game()


func _on_BtnLetter_pressed(letter: String) -> void :
	Audio.play_sfx("ui_put_object")
	if get_node("%LblSaveNameTitle").text.length() < 13:
		get_node("%LblSaveNameTitle").text = get_node("%LblSaveNameTitle").text + letter


func _on_BtnEraseLetter_pressed() -> void :
	Audio.play_sfx("ui_erase")
	var txt: String = get_node("%LblSaveNameTitle").text
	
	if txt.length() > 0:
		get_node("%LblSaveNameTitle").text = txt.trim_suffix(
			txt.right(txt.length() - 1)
		)


func _on_BtnCreatedSaveName_pressed() -> void :
	Audio.play_sfx("ui_accept")
	get_node("%PopupDifficulty").show()
	get_node("%CarouselMenu").active = true


func _on_BtnCancelSaveName_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	get_node("%PopupKeyboard").hide()
	get_node("%BtnSave" + str(VarsGlobal.selected_slot)).grab_focus()



func _on_BtnQuickLoad_pressed() -> void :
	Audio.play_sfx("ui_accept")
	load_game(true)

func _on_BtnNormalLoad_pressed() -> void :
	Audio.play_sfx("ui_accept")
	load_game()

func _on_BtnExitQuickSaveMenu_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	get_node("%PopupQuicksaveExists").hide()
	get_node("%BtnSave" + str(VarsGlobal.selected_slot)).grab_focus()



func _on_BtnDeleteSaveData_pressed() -> void :
	Audio.play_sfx("ui_accept")
	get_node("%PopupDeleteData").show()
	get_node("%BtnReturnFromDeleteMenu").grab_focus()


func _on_BtnReturnFromDeleteMenu_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	get_node("%PopupDeleteData").hide()
	get_node("%BtnSave" + str(VarsGlobal.selected_slot)).grab_focus()


func _on_HelperIconBtnSelectKybrd_visibility_changed() -> void :
	$PopupKeyboard / HBoxContainer2 / HBoxContainer2.visible = $PopupKeyboard / HBoxContainer2 / HBoxContainer2 / HelperIconBtnSelectKybrd.visible


func _on_CarouselMenu_focused_to(item_index: int) -> void :
	if get_node("%PopupDifficulty").visible == true:
		Audio.play_sfx("ui_big_btn_focused")
		
	
	if item_index == 2:
		get_node("%BtnDiffSelected").disabled = true
		get_node("%BtnDiffSelected").text = tr("LOCKED")
		get_node("%CarouselMenu").get_selected_node(2).get_node("CPUParticles2D").visible = true
		get_node("%CarouselMenu").get_selected_node(2).get_node("CPUParticles2D").emitting = true
		
	else:
		get_node("%BtnDiffSelected").disabled = false
		get_node("%BtnDiffSelected").text = tr("ACTION_UI_ACCEPT")
		get_node("%CarouselMenu").get_selected_node(2).get_node("CPUParticles2D").visible = false
		get_node("%CarouselMenu").get_selected_node(2).get_node("CPUParticles2D").emitting = false
		
	get_node("%LblDiffDesc").text = "« " + tr("DIFFICULTY_DESCRIPTION_%d" % [item_index]) + " »"

func _on_BtnDiffL_pressed() -> void :
	get_node("%CarouselMenu").move_to("prev")
func _on_BtnDiffR_pressed() -> void :
	get_node("%CarouselMenu").move_to("next")

func _on_BtnDiffSelected_pressed() -> void :
	
	var diff_selected: int = get_node("%CarouselMenu").selected_index
	
	get_node("%PopupDifficulty").grab_focus()
	
	
	get_node("%PopupDifficulty").hide()
	
	VarsGlobal.reset_data()
	
	if get_node("%LblSaveNameTitle").text == "":
		get_node("%LblSaveNameTitle").text = "XANDRIA"
	
	
	VarsGlobal.game_data["save_name"] = get_node("%LblSaveNameTitle").text
	
	VarsGlobal.set_diff_stats(diff_selected)
	
	
	if Config.get_value("misc", "firsttime_created_savegame", false) == false:
		Config.set_value("misc", "firsttime_created_savegame", true)
		
		match diff_selected:
			0:
				Config.set_value("difficulty", "dynamic_knockback", false)
				Config.set_value("difficulty", "desperation_attack", false)
			1:
				Config.set_value("difficulty", "dynamic_knockback", true)
				Config.set_value("difficulty", "desperation_attack", true)
			2:
				Config.set_value("difficulty", "dynamic_knockback", true)
				Config.set_value("difficulty", "desperation_attack", true)
	
	if DataConf.load_file(data_ini_path) == OK:
		var scene_path_start: String = "res://stages/%s/%s.tscn" % [
			VarsGlobal.selected_stage, DataConf.get_value("info", "start_scene", "")
		]
		Stopwatch.start()
		go_to_scene(scene_path_start)

func _on_HelperIconBtn_visibility_changed() -> void :
	get_node("%HBxHelpers").visible = get_node("%HelperIconBtn").visible

func _on_playstore_signin(is_auth: bool) -> void :
	if is_auth == true and VarsGlobal.selected_stage == "oota":
		get_node("%BtnRestoreData").visible = true


func _on_playstore_snapshots_game_loaded(snapshot: Dictionary) -> void :
	_set_disabled_snapshot_btns(false)
	get_node("%HBxRestoreInfo").visible = true
	if snapshot["content"].empty() == true:
		Audio.play_sfx("ui_incorrect")
		get_node("%LblResultSavegameRestore").modulate = Color.red
		get_node("%LblResultSavegameRestore").text = tr("NO_DATA")
		return
	Audio.play_sfx("ui_success")
	get_node("%LblResultSavegameRestore").modulate = Color.white
	get_node("%LblResultSavegameRestore").text = "%s / %s" % [
		str(snapshot["metadata"]["description"]), 
		str(snapshot["metadata"]["deviceName"])
	]
	_snapshot_game_data_to_load = JSON.parse(snapshot["content"].get_string_from_utf8()).result
	_snapshot_game_data_to_load = VarsGlobal.get_dict_parsed_fixed(_snapshot_game_data_to_load)

func _on_BtnRestoreData_pressed() -> void :
	Audio.play_sfx("ui_accept")
	_snapshot_game_data_to_load = {}
	get_node("%HBxRestoreInfo").visible = false
	get_node("%LblResultSavegameRestore").modulate = Color.white
	get_node("%LblResultSavegameRestore").text = ""
	get_node("%PopupRestoreData").show()
	get_node("%BtnSelectSnapshotPlaystore").grab_focus()


func _on_BtnCloseRestoreDataPopup_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	get_node("%PopupRestoreData").hide()
	focus_first_savegame()

func _on_BtnSelectSnapshotPlaystore_pressed() -> void :
	Audio.play_sfx("ui_accept")
	_snapshot_game_data_to_load = {}
	get_node("%LblResultSavegameRestore").modulate = Color.white
	get_node("%LblResultSavegameRestore").text = tr("LOADING")
	_set_disabled_snapshot_btns(true)
	
	GooglePlayGamesServices.snapshots_show_saved_games(
		
		"%s" % [VarsGlobal.selected_stage], false, true, 50
	)

func _on_SpinBoxSlotSnapshotLoad_value_changed(value_now: int) -> void :
	_slot_to_load = value_now - 1
func _on_SpinBoxSlotSnapshotSave_value_changed(value_now: int) -> void :
	_slot_to_restore = value_now - 1


func _on_BtnStartRestoreSnapshot_pressed() -> void :
	if _snapshot_game_data_to_load.empty() == true:
		Audio.play_sfx("ui_incorrect")
		return
	Audio.play_sfx("ui_accept")
	
	get_node("%LblSnapshotResume").text = get_node("%LblResultSavegameRestore").text
	get_node("%LblSlotNumConfirm").text = str(_slot_to_restore + 1)
	get_node("%PopupRestoreDataConfirmation").show()
	get_node("%BtnConfirmedRestoreSnapshot").grab_focus()


func _on_BtnCancelRestoreSnapshot_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	get_node("%PopupRestoreDataConfirmation").hide()
	get_node("%BtnStartRestoreSnapshot").grab_focus()
func _on_BtnConfirmedRestoreSnapshot_pressed() -> void :
	get_node("%LblFinalSnapshotRestoreResult").text = tr("LOADING")
	get_node("%PopupRestoreDataProccess").show()
	get_node("%BtnAcceptDataRestored").visible = false
	yield(get_tree().create_timer(1), "timeout")
	
	var err: int
	
	err = Savedata.replace_gamedata_to_savefile(
		_snapshot_game_data_to_load, _slot_to_restore, VarsGlobal.selected_stage
	)
	if err == OK:
		get_node("%BtnAcceptDataRestored").visible = true
		Audio.play_sfx("ui_success")
		get_node("%LblFinalSnapshotRestoreResult").text = tr("DATA_RESTORED")
	else:
		Audio.play_sfx("ui_incorrect")
		get_node("%LblFinalSnapshotRestoreResult").text = "ERROR: " + str(err)
	
	get_node("%BtnAcceptDataRestored").grab_focus()


func _on_BtnAcceptDataRestored_pressed() -> void :
	get_tree().reload_current_scene()
