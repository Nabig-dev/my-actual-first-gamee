extends Control

signal dialog_started(dialog_name)
signal dialog_ended(dialog_name)
signal quick_text_ended(txt)
signal dialog_signal_emitted(dialog_name, signal_name)
signal alloy_changed

signal boss_orb_obtained
signal set_changed
signal hud_updated

signal game_exited

var QuickNotif = preload("res://src/ui_elements/quick_notif.tscn")

var QuickText = preload("res://src/ui_elements/quick_text.tscn")

var TutoScreen = preload("res://src/ui_elements/tutorial_screen.tscn")

var RadialLines = preload("res://src/ui_elements/radial_lines.tscn")

var BtnAlchemyItem = preload("res://src/ui_elements/button_alchemy_list_pause.tscn")
var BtnInventoryItem = preload("res://src/ui_elements/button_inventory_item.tscn")

var NegativeStatusIndication = preload("res://src/ui_elements/negative_status_indication.tscn")

var LevelUPNotif = preload("res://src/ui_elements/level_up_notif_full.tscn")

export var area_title: String

export var enabled_quicksave: bool = true

export (Array, NodePath) var minimap_objects
export (Array, Color) var minimap_color_objects

export var dialogs_change_music: bool = true

export var reparent_scenario: bool = true

export var can_pause: bool = true setget _can_pause_enabled

export var can_use_carpatitia: bool = true

var selectable_type_circuits: Array = ["ALLOY", "ACTION", "ABILITY", "SUBWEAPON"]

var gamedata_ec_types: Array = [
	"player_ec_alloy_selected", 
	"player_ec_action_selected", 
	"player_ec_ability_selected", 
	"player_ec_subweapon_selected"
]
var selected_type_circuit: int = 0

var selectable_type_equips: Array = [
	"ACCESORY", "EQUIP_TOP", "EQUIP_MID", "EQUIP_BOTTOM"
]
var selected_type_equip: int = 0

var dialog_active: bool

var show_title: bool

var first_entry_area: bool

var changing_set: bool
var changing_subweapon: bool

var screen_scaling: bool

var _can_choose_carpatitia_death: bool

onready var TimerReady = $TimerReady

onready var Position2DHud = $AspectRatioContainer / HUD / Position2DHud

onready var ViewPortGameScenario = $ViewportContainer / Viewport

onready var ControMiniMap = $AspectRatioContainer / ControlMiniMap
onready var MiniMap = $AspectRatioContainer / ControlMiniMap / Panel / Margin / ViewportContainer / Viewport / MiniMap

onready var BlackRect = $BlackRect

onready var BladeBar = $AspectRatioContainer / HUD / Base / Blade
onready var HPBar = $AspectRatioContainer / HUD / Base / HP
onready var HPDamageBar = $AspectRatioContainer / HUD / Base / HPDamage
onready var HPwarningBar = $AspectRatioContainer / HUD / Base / HPWarning
onready var MPBar = $AspectRatioContainer / HUD / Base / MP
onready var MPBarFull = $AspectRatioContainer / HUD / Base / MPFull
onready var SPBar = $AspectRatioContainer / HUD / Base / SP

onready var StatInjured = $AspectRatioContainer / HUD / Base / NegativeStatsIcons / Injured
onready var StatPoisoned = $AspectRatioContainer / HUD / Base / NegativeStatsIcons / Poisoned
onready var StatCursed = $AspectRatioContainer / HUD / Base / NegativeStatsIcons / Cursed

onready var AnimBladeBloodOutline = $AspectRatioContainer / HUD / AnimBloodOutline
onready var TweenHPBar = $AspectRatioContainer / HUD / TweenHPBar
onready var TimerRecoverStamina = $AspectRatioContainer / HUD / TimerRecoverStamina
onready var TimerRecoverMana = $AspectRatioContainer / HUD / TimerRecoverMana
onready var TimerStartHPTween = $AspectRatioContainer / HUD / TimerStartHPTween
onready var TimerStartRecoverStamina = $AspectRatioContainer / HUD / TimerStartRecoverStamina
onready var TimerReduceHPByPoison = $AspectRatioContainer / HUD / TimerReduceHPByPoison
onready var TimerReduceMPByCurse = $AspectRatioContainer / HUD / TimerReduceMPByCurse
onready var TimerRemovePoison = $TimerRemovePoison
onready var TimerRemoveCurse = $TimerRemoveCurse
onready var TimerRemoveInjury = $TimerRemoveInjury
onready var TimerLoadedScenario = $TimerLoadedScenario
onready var TimerNoNegStatusPoison = $TimerNoNegStatusPoison
onready var TimerNoNegStatusCurse = $TimerNoNegStatusCurse
onready var TimerNoNegStatusInjury = $TimerNoNegStatusInjury

onready var TimerRefreshAlchemyBtns = $TimerRefreshAlchemyBtns

onready var CtrlPause = $CtrlPause
onready var CtrlPauseEquip = $CtrlPause / Equip
onready var CtrlMap = $CtrlPause / Map

onready var SliderSfx = $CtrlPause / Equip / VBoxContainer / EquipTabContainer / OPTIONS / ScrollContainer / MarginContainer / VBxOptionsBtn / HBox_sfx / HSlider
onready var SliderBgm = $CtrlPause / Equip / VBoxContainer / EquipTabContainer / OPTIONS / ScrollContainer / MarginContainer / VBxOptionsBtn / HBox_bgm / HSlider
onready var SliderVoice = $CtrlPause / Equip / VBoxContainer / EquipTabContainer / OPTIONS / ScrollContainer / MarginContainer / VBxOptionsBtn / HBox_voice / HSlider

onready var MapPointer = get_node("%MapPointer")
onready var Node2DMap = get_node("%NodeMap")

func _ready() -> void :
	
	
	if Features.has("mobile") == true:
		get_node("%BtnSaveMarker").visible = false
	
	set_visible_vgamepad()
	update_hud_switch_subweapon_icon()
	get_node("%ControlStats").visible = false
	get_node("%ControlChangeSet").visible = false
	get_node("%CurrentSubweaponSprite").visible = false
	update_sets_labels()
	
	
	if Features.has("mobile") == true:
		get_node("%BtnScreenFilter").visible = false
	
	if (
		Features.has("switch")
		or Features.has("xbox")
		or Features.has("ps")
		
	):
		get_node("%BtnFPSLimit").visible = false
	
	
	
	SliderSfx.value = Config.get_value("audio", "sound_effect_player", 1.0) * 100
	$CtrlPause / Equip / VBoxContainer / EquipTabContainer / OPTIONS / ScrollContainer / MarginContainer / VBxOptionsBtn / HBox_sfx / LblNum.text = String(SliderSfx.value).pad_zeros(0)
	SliderSfx.connect("value_changed", self, "_on_AudioHSlider_value_changed", ["sound_effect_player"])
	
	SliderBgm.value = Config.get_value("audio", "bgm", 1.0) * 100
	$CtrlPause / Equip / VBoxContainer / EquipTabContainer / OPTIONS / ScrollContainer / MarginContainer / VBxOptionsBtn / HBox_bgm / LblNum.text = String(SliderBgm.value).pad_zeros(0)
	SliderBgm.connect("value_changed", self, "_on_AudioHSlider_value_changed", ["bgm"])
	
	SliderVoice.value = Config.get_value("audio", "voice", 1.0) * 100
	$CtrlPause / Equip / VBoxContainer / EquipTabContainer / OPTIONS / ScrollContainer / MarginContainer / VBxOptionsBtn / HBox_voice / LblNum.text = String(SliderVoice.value).pad_zeros(0)
	SliderVoice.connect("value_changed", self, "_on_AudioHSlider_value_changed", ["voice"])
	
	$BlackRect.visible = true
	
	Audio.underwater_filter_enabled(false)
	
	Engine.time_scale = 1
	
	
	_on_ThermalBar_stopped()
	get_node("%ThermalBarHeat").value = ThermalBar.value
	get_node("%ThermalBarHeat").max_value = ThermalBar.max_value
	get_node("%ThermalBarCold").value = ThermalBar.value
	get_node("%ThermalBarCold").max_value = ThermalBar.max_value
	get_node("%ThermalBarUnderWater").value = ThermalBar.value
	get_node("%ThermalBarUnderWater").max_value = ThermalBar.max_value
	
	ThermalBar.emit_signal("value_changed")
	
	
	ThermalBar.connect("started", self, "_on_ThermalBar_started")
	
	ThermalBar.connect("value_changed", self, "_on_ThermalBar_value_changed")
	
	ThermalBar.connect("max_reached", self, "_on_ThermalBar_max_reached")
	
	ThermalBar.connect("stopped", self, "_on_ThermalBar_stopped")
	
	Achievments.connect("achievment_obtained", self, "_on_achievement_obtained")
	
	get_tree().paused = false
	CtrlPause.visible = false
	CtrlPauseEquip.visible = false
	CtrlMap.visible = false
	
	update_hud_values()
	
	
	_on_TimerStartRecoverStamina_timeout()
	
	
	HPDamageBar.value = 0
	
	ControMiniMap.visible = false
	
	
	
	
	
	
	
	
	
	
	
	get_tree().get_root().connect("size_changed", self, "_on_MainViewport_size_changed")
	
	_on_MainViewport_size_changed()
	
	VarsGlobal.GameInterface = self
	
	
	Gamepad.connect("gamepad_connection_changed", self, "_on_gamepad_connection_changed")
	
	
	
	var i: int = 0
	for obj_path in minimap_objects:
		var minimap_color = Color("ffffff")
		if minimap_color_objects.empty() == false:
			minimap_color = minimap_color_objects[i]
		MiniMap.add_object(get_node_or_null(obj_path), minimap_color)
		i += 1
	
	if reparent_scenario:
		_reparent_node()
	
	refresh_minimap_config()
	
	
	var scene_name = get_tree().get_current_scene().get_filename().get_file().replace(".tscn", "")
	VarsGlobal.game_data["current_room"] = scene_name
	VarsGlobal.game_data["current_room_path"] = get_tree().get_current_scene().get_filename()
	
	if VarsGlobal.game_data["visited_rooms"].has(scene_name) == false:
		VarsGlobal.game_data["visited_rooms"].append(scene_name)
	
	load_map_stage()
	
	
	if Stopwatch.is_active == false:
		Stopwatch.start()
	
	
	if (
		area_title.empty() == false
		and VarsGlobal.game_data["current_area_title"] != area_title
	):
		VarsGlobal.game_data["current_area_title"] = area_title
		
		if VarsGlobal.game_data["visited_areas_title"].has(area_title) == false:
			first_entry_area = true
		show_title = true
	
	
	update_hud_values(false)
	
	update_vhs_setting()
	
	TimerReady.start()
	yield(TimerReady, "timeout")
	
	MiniMap.refresh_minimap_limits()
	
	apply_negative_status()
	start_timers_negative_status()
	
	

	
	hide_blackrect()

	

func _notification(what: int) -> void :
	if (
		what == NOTIFICATION_WM_FOCUS_OUT
		and get_tree().paused == false
		and Features.has("debug") == false
	):
		pause_game(0)

func _process(_delta: float) -> void :
	
	if (
		DebugMenu.using_console == true
		or BugReport.visible == true
	):
		return
	
	
	if (
		VarsGlobal.game_data["player_hp_now"] < 1
		and _can_choose_carpatitia_death == true
	):
		if Input.is_action_just_pressed("ui_accept"):
			_on_BtnContinueFromDeath_pressed()
		elif Input.is_action_just_pressed("ui_cancel"):
			_on_BtnUseCarpatitiaDeath_pressed()
		return
	
	
	

	
	
	if BlackRect.modulate.a == 0:
		if Input.is_action_just_pressed("ui_start"):
			pause_game(0)
		elif Input.is_action_just_pressed("ui_select"):
			pause_game(1)
	
	
	if Input.is_action_just_pressed("quickmenu"):
		if ElementalCircuits.was_obtained(
			GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.MULTIPLE_EQUIPMENT
		) == true:
			changing_set = true
			if Config.get_value("gameplay", "quickmenu_details", false) == true:
				get_node("%ControlStats").visible = true
			get_node("%ControlChangeSet").visible = true
			update_sets_labels()
		changing_subweapon = true
		
		
		update_set_info_quick()
	elif Input.is_action_just_released("quickmenu"):
		changing_set = false
		changing_subweapon = false
		get_node("%ControlStats").visible = false
		get_node("%ControlChangeSet").visible = false
		get_node("%CurrentSubweaponSprite").visible = false
	
	if changing_set == true:
		
		var gamepad_connected: bool = Gamepad.is_controller_connected()
		var vpad_visible: bool = Config.get_value(
			"touch_screen_btn", "visible", false
		)
		var vpad_always_visible: bool = Config.get_value(
			"touch_screen_btn", "always_visible", false
		)
		var can_change_set: bool = true
		
		
		if (
			gamepad_connected == false
			and (vpad_visible == true or vpad_always_visible == true)
		):
			can_change_set = false
		if Input.is_action_just_pressed("ui_focus_prev") and can_change_set == true:
			get_node("%ButtonSwitchSetAlchemy").switch_set("prev", false)
			update_sets_labels()
			update_set_info_quick()
			emit_signal("set_changed")
		elif Input.is_action_just_pressed("ui_focus_next") and can_change_set == true:
			get_node("%ButtonSwitchSetAlchemy").switch_set("next", false)
			update_sets_labels()
			update_set_info_quick()
			emit_signal("set_changed")

				

	
	if CtrlMap.visible == true:
		
		var current_tab = get_node("%MapTabContainer").get_current_tab_control().name
		
		match current_tab:
			"MAP":
				var popup_marker_visible: bool = get_node("%PopupMarkerMenu").visible
				
				if popup_marker_visible == false:
					
					if Input.is_action_pressed("ui_up"):
						Node2DMap.move(Vector2.UP)
					elif Input.is_action_pressed("ui_down"):
						Node2DMap.move(Vector2.DOWN)
					elif Input.is_action_pressed("ui_left"):
						Node2DMap.move(Vector2.LEFT)
					elif Input.is_action_pressed("ui_right"):
						Node2DMap.move(Vector2.RIGHT)
					else:
						Audio.stop_sfx("ui_move_map")
				else:
						Audio.stop_sfx("ui_move_map")
			
				
				
				if Input.is_action_just_pressed("ui_cancel"):
					if popup_marker_visible == false:
						_on_BtnZoomMap_pressed()
					
					
				
				
				
				if Input.is_action_just_pressed("ui_start"):
					if popup_marker_visible == false:
						_on_BtnCenterMap_pressed()
					
					
				
				
				
				if Input.is_action_just_pressed("ui_accept"):
					if popup_marker_visible == false:
						_on_BtnAddMarkerMap_pressed()
					elif get_focus_owner() is TextureButton:
						_on_BtnSaveMarker_pressed()
		
			"FINDINGS":
				if Input.is_action_pressed("ui_accept"):
					get_node("%ScrollContainerNote").set_v_scroll(
						get_node("%ScrollContainerNote").get_v_scroll() + 3
					)
					
						
				elif Input.is_action_pressed("ui_cancel"):
					get_node("%ScrollContainerNote").set_v_scroll(
						get_node("%ScrollContainerNote").get_v_scroll() - 3
					)
					
						
			"KEYSOBJECTS":
				if Input.is_action_pressed("ui_accept"):
					get_node("%ScrollContainerKeys").set_v_scroll(
						get_node("%ScrollContainerKeys").get_v_scroll() + 3
					)
				elif Input.is_action_pressed("ui_cancel"):
					get_node("%ScrollContainerKeys").set_v_scroll(
						get_node("%ScrollContainerKeys").get_v_scroll() - 3
					)
		
		
		if Input.is_action_just_pressed("ui_focus_prev"):
			_select_new_tab(get_node("%MapTabContainer"), "prev")
		if Input.is_action_just_pressed("ui_focus_next"):
			_select_new_tab(get_node("%MapTabContainer"), "next")

	
	if CtrlPauseEquip.visible == true:
		
		var current_tab = get_node("%EquipTabContainer").get_current_tab_control().name
		
		match current_tab:
			"INVENTORY":
				if Input.is_action_just_pressed("ui_accept"):
					
					_on_BtnUseItemInventory_pressed()
			"ALCHEMY":
				if Input.is_action_just_pressed("ui_select") and ElementalCircuits.was_obtained(
					GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.MULTIPLE_EQUIPMENT
				) == true:
					get_node("%ButtonSwitchSetAlchemy").switch_set()
				elif Input.is_action_just_pressed("ui_left"):
					get_node("%BtnPrevCircuitType").emit_signal("pressed")
				elif Input.is_action_just_pressed("ui_right"):
					get_node("%BtnNextCircuitType").emit_signal("pressed")
				elif Input.is_action_just_pressed("ui_accept"):
					_on_BtnEquipCircuit_pressed()
			"EQUIP":
				

				if Input.is_action_just_pressed("ui_left"):
					update_equip_buttons(
						FuncsArrays.get_new_position_on_array(
							selectable_type_equips, selected_type_equip, "prev"
						)
					)
				elif Input.is_action_just_pressed("ui_right"):
					update_equip_buttons(
						FuncsArrays.get_new_position_on_array(
							selectable_type_equips, selected_type_equip, "next"
						)
					)
				elif Input.is_action_just_pressed("ui_accept"):
					_on_BtnEquipItem_pressed()
				
				get_node("%BtnEquipType" + str(selected_type_equip)).pressed = true

		
		if Input.is_action_just_pressed("ui_focus_prev"):
			_select_new_tab(get_node("%EquipTabContainer"), "prev")
		if Input.is_action_just_pressed("ui_focus_next"):
			_select_new_tab(get_node("%EquipTabContainer"), "next")

func check_if_can_use_carpatitia_death() -> void :
	
	
	
	if VarsGlobal.game_data["player_inventory"].has(
		GVar.INVENTORY_ITEM.CARPATITIA
	) and VarsGlobal.game_data["last_save_room_used"] != "" and VarsGlobal.GameScenario.boss_battle_active == false:
		
		if VarsGlobal.game_data["player_inventory"][
			GVar.INVENTORY_ITEM.CARPATITIA
		] >= 2:
			_can_choose_carpatitia_death = true
			get_node("%ControlUseCarpatitia").visible = true
			get_node("%AnimationPlayerDeath").stop(false)

func apply_negative_status(negative_status: String = "NONE") -> void :
	if negative_status != "NONE":
		
		if (
			(negative_status == "POISONED" and VarsGlobal.game_data["player_poisoned"] == false)
			or (negative_status == "CURSED" and VarsGlobal.game_data["player_cursed"] == false)
			or (negative_status == "INJURED" and VarsGlobal.game_data["player_injured"] == false)
		):
			var ObjInstance = NegativeStatusIndication.instance()
			ObjInstance.status = negative_status
			VarsGlobal.Player.call_deferred("add_child", ObjInstance)
			yield(get_tree(), "idle_frame")
			ObjInstance.global_position.y -= 60

func start_timers_negative_status() -> void :
	
	
	
	if VarsGlobal.game_data["player_poisoned"]:
		TimerReduceHPByPoison.start()
		if TimerRemovePoison.is_stopped() == true:
			TimerRemovePoison.start()
	
	if VarsGlobal.game_data["player_cursed"]:
		TimerReduceMPByCurse.start()
		if TimerRemoveCurse.is_stopped() == true:
			TimerRemoveCurse.start()
	
	if VarsGlobal.game_data["player_injured"]:
		if TimerRemoveInjury.is_stopped() == true:
			TimerRemoveInjury.start()

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
	

func pause_game(what_show: int = 0) -> void :
	
	if DebugMenu.using_console == true or TimerLoadedScenario.is_stopped() == false:
		Audio.play_sfx("ui_incorrect")
		return
	
	
	
	if (
		can_pause == false
		or VarsGlobal.game_data["player_hp_now"] < 1
		or dialog_active == true
	):
		return
	
	
	
	if get_tree().paused == true and (
		(what_show == 0 and CtrlMap.visible == true)
		or (what_show == 1 and CtrlPauseEquip.visible == true)
	):
		return
	
	CtrlPauseEquip.visible = false
	CtrlMap.visible = false
	
	$VirtualGamepad.stop_joystick()
	
	
	if get_tree().paused == true:
		
		DebugMenu.layer = 1
		
		get_node("%PopupMarkerMenu").hide()
		CtrlPause.visible = false
		CtrlPauseEquip.visible = false
		CtrlMap.visible = false
		get_tree().paused = false
		Audio.play_sfx("ui_cancel")
		Audio.stop_sfx("ui_move_map")
		
		
		Input.action_release("ui_up")
		Input.action_release("ui_down")
		Input.action_release("ui_left")
		Input.action_release("ui_right")
		Input.action_release("ui_focus_next")
		
		
	
	
	else:
		
		
		if get_tree().get_nodes_in_group("levelup_notif").size() > 0:
			return
		
		DebugMenu.layer = - 1
		
		CtrlPause.visible = true
		get_tree().paused = true
		Audio.play_sfx("ui_accept")
		
		
		
		
		
		if (
			enabled_quicksave == false
			or Savedata.game_exists() == false
		):
			get_node("%BtnQuicksaveAndExit").disabled = true
		
		
		if ElementalCircuits.was_obtained(
			GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.MULTIPLE_EQUIPMENT
		) == true:
			get_node("%ButtonSwitchSetAlchemy").visible = true
			get_node("%ButtonSwitchSetAlchemy").refresh_letter()
			
			
			
		else:
			
			
			pass
		
		match what_show:
			0:
				CtrlPauseEquip.visible = true
				update_stats_pause()
				
				_on_EquipTabContainer_tab_changed(0)
			1:
				CtrlMap.visible = true
				_on_MapTabContainer_tab_changed(0)

	yield(get_tree(), "idle_frame")

func switch_subweapon(dir: String = "next") -> void :
	var subweapons: Array = [ - 1]
	subweapons.append_array(VarsGlobal.game_data["player_ec_subweapon"])
	
	
	var index_select: int = subweapons.find(
		VarsGlobal.game_data["player_ec_subweapon_selected"][0], 
		0
	)
	
	var current_subweapon: int = 0
	

	
	

	
	index_select = FuncsArrays.get_new_position_on_array(
		subweapons, index_select, dir
	)
	
	current_subweapon = subweapons[index_select]
	
	VarsGlobal.game_data["player_ec_subweapon_selected"] = [
		current_subweapon, 
		current_subweapon, 
		current_subweapon, 
		current_subweapon
	]
	
	update_hud_switch_subweapon_icon()

func update_hud_switch_subweapon_icon() -> void :
	var current_subweapon = VarsGlobal.game_data["player_ec_subweapon_selected"][0]
	if current_subweapon == - 1:
		get_node("%CurrentSubweaponSprite").frame = 9
	else:
		get_node("%CurrentSubweaponSprite").frame = current_subweapon

func update_vhs_setting() -> void :

	get_node("%CRTVHSAdd").visible = ScreenFilter.vhs_add

func update_sets_labels() -> void :
	var set_now: int = VarsGlobal.game_data["player_current_set"]
	var sets: = ["A", "B", "C"]
	get_node("%LblSet").text = sets[set_now]
	get_node("%LblSetNext").text = sets[
		FuncsArrays.get_new_position_on_array(
			sets, set_now, "next"
		)
	]
	get_node("%LblSetPrev").text = sets[
		FuncsArrays.get_new_position_on_array(
			sets, set_now, "prev"
		)
	]
	
	
	
	match sets[set_now]:
		"A":
			get_node("%LightSet").modulate = Color("ff00b9")
		"B":
			get_node("%LightSet").modulate = Color("08ffff")
		"C":
			get_node("%LightSet").modulate = Color("f91ff900")
		"D":
			get_node("%LightSet").modulate = Color("f9f9de00")
		

func update_stats_pause() -> void :
	
	var time_elapsed = Stopwatch.get_friendly_time(
		Stopwatch.millis_elapsed + VarsGlobal.game_data["millis_elapsed"]
	)
	
	get_node("%LblStatsHP").text = "%s/%s" % [
		str(VarsGlobal.game_data["player_hp_now"]).pad_zeros(3), 
		str(VarsGlobal.game_data["player_hp_max"]).pad_zeros(3)
	]
	get_node("%InvProgressHP").max_value = VarsGlobal.game_data["player_hp_max"]
	get_node("%InvProgressHP").value = VarsGlobal.game_data["player_hp_now"]
	
	
	get_node("%LblStatsMP").text = "%s/%s" % [
		str(VarsGlobal.game_data["player_mp_now"]).pad_zeros(3), 
		str(VarsGlobal.game_data["player_mp_max"]).pad_zeros(3)
	]
	get_node("%InvProgressMP").max_value = VarsGlobal.game_data["player_mp_max"]
	get_node("%InvProgressMP").value = VarsGlobal.game_data["player_mp_now"]
	
	
	get_node("%InvProgressBL").max_value = VarsGlobal.game_data["player_bl_max"]
	get_node("%InvProgressBL").value = VarsGlobal.game_data["player_bl_now"]
	get_node("%LblStatsBL").text = "%s/%s" % [
		str(VarsGlobal.game_data["player_bl_now"]).pad_zeros(3), 
		str(VarsGlobal.game_data["player_bl_max"]).pad_zeros(3)
	]
	

	get_node("%LblLVL").text = "LVL %02d" % [
		VarsGlobal.game_data["current_level"]
	]
	
	
	
	
	
	
	get_node("%LblExpNow").text = str(VarsGlobal.game_data["exp"])
	get_node("%LblExpToNext").text = str(VarsGlobal.get_exp_next())
	

	get_node("%LblStatsTIME").text = "%s: %s:%s:%s" % [
		tr("TIME"), 
		str(time_elapsed["hours"]).pad_zeros(2), 
		str(time_elapsed["minutes"]).pad_zeros(2), 
		str(time_elapsed["seconds"]).pad_zeros(2)
	]
	
	get_node("%LblStatsMONEY").text = "C$ %s" % [
		str(VarsGlobal.game_data["player_money"]).pad_zeros(6), 
	]
	
	
	var status_list: Array = []
	var label_text: String
	
	if VarsGlobal.game_data["player_injured"] == true:
		status_list.append(tr("INJURED"))
	if VarsGlobal.game_data["player_poisoned"] == true:
		status_list.append(tr("POISONED"))
	if VarsGlobal.game_data["player_cursed"] == true:
		status_list.append(tr("CURSED"))
	
	if status_list.size() == 0:
		get_node("%LblNegativeStatus").visible = false
	else:
		get_node("%LblNegativeStatus").visible = true
		
		for s in status_list:
			label_text = label_text + ", " + s
		
		label_text = label_text.lstrip(",")

	get_node("%LblNegativeStatus").text = "( ! ) %s." % [label_text]

func update_ui_circuit() -> void :
	get_node("%LblTypeCircuit").text = tr(selectable_type_circuits[selected_type_circuit])
	get_node("%UICircuit").circuit_mode = selected_type_circuit - 1
	get_node("%UICE_ALLOY").visible = false

func update_attrb_elemental_icons(attrbs: Array) -> void :
	
	
	var attrbs_elemental_icons: = get_node("%HBxAttrbElement").get_children()
	
	var i: int = 0
	for at in attrbs_elemental_icons:
		if at.name in attrbs:
			attrbs_elemental_icons[i].visible = true
		else:
			attrbs_elemental_icons[i].visible = false
		i += 1

func update_alchemy_buttons() -> void :
	var VBxAlchemyBtns = get_node("%VBxAlchemyBtns")
	var list_items: Array = [ - 1]
	var BtnAlchemyInstance: Button
	
	
	for b in VBxAlchemyBtns.get_children():
		b.queue_free()
	
	match selected_type_circuit:
		0:
			list_items.append_array(VarsGlobal.game_data["player_ec_alloy"].keys())
		1:
			list_items.append_array(VarsGlobal.game_data["player_ec_action"])
		2:
			list_items.append_array(VarsGlobal.game_data["player_ec_ability"])
		3:
			list_items.append_array(VarsGlobal.game_data["player_ec_subweapon"])

	
	for i in list_items:
		BtnAlchemyInstance = BtnAlchemyItem.instance()
		
		BtnAlchemyInstance.ide = i
		BtnAlchemyInstance.type = selected_type_circuit
		VBxAlchemyBtns.add_child(BtnAlchemyInstance)
		
		
		BtnAlchemyInstance.connect(
			"focus_entered", self, 
			"_on_BtnAlchemy_focus_entered", 
			[BtnAlchemyInstance.type, BtnAlchemyInstance.ide]
		)
		
		
		if i == VarsGlobal.game_data[gamedata_ec_types[selected_type_circuit]][
			VarsGlobal.game_data["player_current_set"]
		]:
			
			
			BtnAlchemyInstance.grab_focus()
			
			if selected_type_circuit in [0, 1, 3]:
				BtnAlchemyInstance.text = "=> " + BtnAlchemyInstance.text
			
			TimerRefreshAlchemyBtns.start()

func update_equip_buttons(type_select: int) -> void :
	selected_type_equip = type_select
	
	
	var _added_equip_items: Array

	var EquipSheet = CSVDBLoader.get_db("equipment_objects")
	var VBxEquipBtns = get_node("%VBxEquipBtns")
	var equip_items: Array = [ - 1]
	var BtnEquipInstance: Button
	
	
	equip_items.append_array(VarsGlobal.game_data["player_equip_items"])
	
	get_node("%LblEquipTypeTitle").text = tr(selectable_type_equips[type_select])
	
	
	for b in VBxEquipBtns.get_children():
		b.queue_free()
		
	
	for e in equip_items:
		
		
		
		if _added_equip_items.has(e) == false:
			
			var add_button: bool = false
			
			if e == - 1:
				add_button = true
			
			elif type_select == EquipSheet[GVar.EQUIPMENT.keys()[e + 1]]["type"]:
				add_button = true
			
			if add_button == true:
				
				BtnEquipInstance = Button.new()
				
				
				BtnEquipInstance.editor_description = str(e)
				
				if e == - 1:
					BtnEquipInstance.text = tr("NONE")
				else:
					BtnEquipInstance.text = tr(GVar.EQUIPMENT.keys()[e + 1] + "_TITLE")
				
				VBxEquipBtns.add_child(BtnEquipInstance)
				
				_added_equip_items.append(e)
				
				
				BtnEquipInstance.focus_next = BtnEquipInstance.get_path()
				BtnEquipInstance.focus_previous = BtnEquipInstance.get_path()
				
				
				
				BtnEquipInstance.connect(
					"focus_entered", self, "_on_BtnEquipItem_focus_entered", [e]
				)
				
				
				if VarsGlobal.game_data["player_equip_%d" % [type_select]][
					VarsGlobal.game_data["player_current_set"]
				] == e:
					BtnEquipInstance.text = "=> " + BtnEquipInstance.text
					BtnEquipInstance.grab_focus()

func update_inventory_grid() -> void :
	
	var grid_container = get_node("%InventoryGridContainer")
	
	
	for itemgrid in grid_container.get_children():
		itemgrid.queue_free()
	
	
	var item_count: int = 0
	
	for itm in VarsGlobal.game_data["player_inventory"]:
		var BtnInvItemInstance = BtnInventoryItem.instance()
		BtnInvItemInstance.item = itm
		
		if VarsGlobal.game_data["player_inventory"][itm] > 0:
			
			BtnInvItemInstance.connect(
				"focus_entered", self, "_BtnItemInventory_focus_entered", 
				[itm]
			)
			grid_container.add_child(BtnInvItemInstance)
			
			if item_count == 0:
				BtnInvItemInstance.grab_focus()
			
			item_count += 1
	
	if item_count == 0:
		get_node("%BtnUseItemInventory").disabled = true
		get_node("%InventoryItemTitle").text = tr("EMPTY_INVENTORY")
		get_node("%InventoryItemDesc").text = ""
		get_node("%InventoryItemQuantity").text = ""
	else:
		get_node("%BtnUseItemInventory").disabled = false

func update_inventory_data(item_ide: int) -> void :
	var item_string = GVar.INVENTORY_ITEM.keys()[item_ide]
	var quantity: int = VarsGlobal.game_data["player_inventory"][item_ide]
	
	get_node("%InventoryItemTitle").text = tr(item_string + "_TITLE")
	
	get_node("%InventoryItemDesc").text = tr(item_string + "_DESC")
	
	get_node("%InventoryItemQuantity").text = "(%d)" % [
		quantity
	]
	if quantity == 0:
		get_node("%BtnUseItemInventory").disabled = true
	else:
		get_node("%BtnUseItemInventory").disabled = false

func update_hud_values(start_hp_tween: bool = true) -> void :
	
	
	
	
	
	if ElementalCircuits.was_obtained(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.MULTIPLE_EQUIPMENT
	) == true:
		update_sets_labels()
		get_node("%LblSet").visible = true
	else:
		get_node("%LblSet").visible = false
	
	
	HPDamageBar.value = HPBar.value
	
	HPBar.value = VarsGlobal.game_data["player_hp_now"]
	HPBar.max_value = VarsGlobal.game_data["player_hp_max"]
	HPwarningBar.value = HPBar.value
	HPwarningBar.max_value = HPBar.max_value
	HPDamageBar.max_value = HPBar.max_value
	
	
	HPwarningBar.visible = (
		FuncsNumbers.get_percentage(HPBar.value, HPBar.max_value) <= 40.0
	)
	
	
	if FuncsNumbers.get_percentage(HPBar.value, HPBar.max_value) < 20.0:
		get_node("%AnimBloodLayout").play("heartbeat")
	else:
		get_node("%AnimBloodLayout").play("RESET")
	
	
	if start_hp_tween == true:
		TimerStartHPTween.start()
	
	MPBar.value = VarsGlobal.game_data["player_mp_now"]
	MPBar.max_value = VarsGlobal.game_data["player_mp_max"]
	
	MPBarFull.visible = (MPBar.value == MPBar.max_value)
	
	BladeBar.value = VarsGlobal.game_data["player_bl_now"]
	BladeBar.max_value = VarsGlobal.game_data["player_bl_max"]
	
	
	if BladeBar.value >= 20:
		BladeBar.modulate.a = 1
	else:
		BladeBar.modulate.a = 0.4
	
	
	if BladeBar.value == BladeBar.max_value:
		AnimBladeBloodOutline.play("show")
	else:
		AnimBladeBloodOutline.play("hide")
	
	SPBar.value = VarsGlobal.game_data["player_sp_now"]
	SPBar.max_value = VarsGlobal.game_data["player_sp_max"]
	
	if FuncsNumbers.get_percentage(SPBar.value, SPBar.max_value) < 40.0:
		SPBar.modulate.a = 0.4
	else:
		SPBar.modulate.a = 1.0
		
	get_node("%LblHPQuick").text = "%03d" % [
		VarsGlobal.game_data["player_hp_now"]
	]
	get_node("%LblMPQuick").text = "%03d" % [
		VarsGlobal.game_data["player_mp_now"]
	]
	get_node("%LblBLQuick").text = "%03d" % [
		VarsGlobal.game_data["player_bl_now"]
	]
	
	update_set_info_quick()
	
	
	StatInjured.visible = VarsGlobal.game_data["player_injured"]
	StatPoisoned.visible = VarsGlobal.game_data["player_poisoned"]
	StatCursed.visible = VarsGlobal.game_data["player_cursed"]
	
	TimerRecoverMana.start()
	
	emit_signal("hud_updated")

func update_set_info_quick() -> void :
	var ec_action_string = ElementalCircuits.get_circuit_string(
		GVar.EC_MODE.ACTION, 
		VarsGlobal.game_data["player_ec_action_selected"][
			VarsGlobal.game_data["player_current_set"]
		], 
		true
	)
	var ec_alloy_string = (
		tr(GVar.ALLOYS.keys()[
			VarsGlobal.game_data["player_ec_alloy_selected"][
			VarsGlobal.game_data["player_current_set"]
		] + 1
		] + "_TITLE")
	)
	
	if VarsGlobal.game_data["player_ec_action_selected"][
		VarsGlobal.game_data["player_current_set"]
	] == - 1:
		ec_action_string = "- - -"
	if VarsGlobal.game_data["player_ec_alloy_selected"][
		VarsGlobal.game_data["player_current_set"]
	] == - 1:
		ec_alloy_string = "- - -"

	get_node("%LblSetInfo").text = "%s\n%s" % [
		ec_alloy_string, 
		ec_action_string
	]

func update_stamina_stats() -> void :
	TimerStartRecoverStamina.stop()
	TimerRecoverStamina.stop()
	TimerStartRecoverStamina.start()

func refresh_minimap_config() -> void :
	ControMiniMap.visible = Config.get_value("gameplay", "show_minimap", true)
	ControMiniMap.modulate.a = Config.get_value("gameplay", "minimap_opacity", 0.8)

func set_visible_hud_elements(val: bool = true) -> void :
	$AspectRatioContainer.visible = val

func set_visible_vgamepad(val: bool = true) -> void :
	$VirtualGamepad.visible = val

func hide_blackrect() -> void :
	
	if $Tween.is_active() or BlackRect.modulate.a == 0:
		return
	
	$Tween.interpolate_property(
		BlackRect, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.2
	)
	$Tween.start()

func show_notif_item_obtained(txt: String = "Test") -> void :
	var Notif = QuickNotif.instance()
	Notif.text = txt
	get_node("%VBxQuickNotif").add_child(Notif)

func show_levelup_message(txt: String) -> void :
	get_node("%LevelUpMessage").show_title(txt)
	update_hud_values(false)

func start_dialog(timeline: String) -> void :
	var new_dialog = Dialogic.start(timeline)
	
	new_dialog.connect("timeline_start", self, "_on_DialogStart")
	new_dialog.connect("timeline_end", self, "_on_DialogEnd")
	new_dialog.connect("dialogic_signal", self, "_on_DialogSignal", [timeline])
	
	add_child(new_dialog)

func show_levelup_reached() -> void :
	var ObjInstance = LevelUPNotif.instance()
	update_hud_values(false)
	call_deferred("add_child", ObjInstance)
	

func show_flash(animation_player: String = "flash", clr: Color = Color("c6c6c6")) -> void :
	$Flash.color = clr
	get_node("%AnimationPlayerFlash").play(animation_player)

func show_circuit_desc(circuit: int, type: int) -> void :
	var TutoScr = TutoScreen.instance()
	add_child(TutoScr)
	TutoScr.connect("started", self, "_on_DialogStart", ["tuto_circuit"])
	TutoScr.connect("ended", self, "_on_DialogEnd", ["tuto_circuit"])
	TutoScr.start_circuit_message(circuit, type)

func show_tuto_screen(what: int, chang_hud_v: bool = true) -> void :
	var TutoScr = TutoScreen.instance()
	add_child(TutoScr)
	TutoScr.connect("started", self, "_on_DialogStart", ["tuto_" + str(what)])
	TutoScr.connect("ended", self, "_on_DialogEnd", ["tuto_" + str(what), chang_hud_v])
	TutoScr.start(what)

func show_boss_title(boss_txt: String) -> void :
	get_node("%BossTitle").show_title(boss_txt)

func show_radial_lines(time_show: float = 1.0) -> void :
	var RadialInstance = RadialLines.instance()
	RadialInstance.time_show = time_show
	add_child(RadialInstance)

func show_quick_text(txt: String, where_node: Object, offset_y: int = - 75) -> void :
	var QuickTxtInstance = QuickText.instance()
	
	QuickTxtInstance.text = tr(txt)
	QuickTxtInstance.rect_position.y = offset_y
	QuickTxtInstance.connect("text_ended", self, "_on_quick_text_ended", [txt])
	if is_instance_valid(where_node):
		where_node.add_child(QuickTxtInstance)

func get_paper(paperid: int) -> void :
	
	if VarsGlobal.game_data["player_notes"].has(paperid):
		return
	Audio.play_sfx("paper_get")
	
	VarsGlobal.game_data["player_notes"].append(paperid)
	Notification.show_notif(
		tr("FINDINGS") + ": %s" % [
			tr(GVar.NOTES.keys()[paperid] + "_TITLE")
		]
	)

func _select_new_tab(TabCont: TabContainer, direction: String) -> void :
	var _tabs = TabCont.get_children()
	yield(get_tree(), "idle_frame")
	Audio.play_sfx("ui_big_btn_focused")
	TabCont.set_current_tab(
		FuncsArrays.get_new_position_on_array(_tabs, TabCont.current_tab, direction)
	)

func _reparent_node() -> void :
	
	var GameScenarioNode = get_parent().get_node_or_null("GameScenario")
	
	if GameScenarioNode != null:
		
		refresh_minimap_config()
		
		get_parent().call_deferred("remove_child", GameScenarioNode)
		yield(get_tree(), "idle_frame")
		GameScenarioNode.reparented = true
		ViewPortGameScenario.add_child(GameScenarioNode)
		
		if VarsGlobal.Player != null and VarsGlobal.Player.has_signal("stats_changed"):
			VarsGlobal.Player.connect("stats_changed", self, "update_hud_values")

func _on_gamepad_connection_changed(connected: bool) -> void :
	if connected == false:
		pause_game(0)

func _on_achievement_obtained(id_ach: String) -> void :
	get_node("%AchievementNotif").show_notif(id_ach)

func _on_GameInterface_tree_exiting() -> void :
	VarsGlobal.GameInterface = null
	
	
	Audio.stop_sfx("ec_charging")

func _on_DialogStart(_timeline_name: String) -> void :
	dialog_active = true
	
	set_visible_hud_elements(false)
	
	
	if dialogs_change_music == true:
		Audio.change_music_style("low")
	get_tree().paused = true
	emit_signal("dialog_started", _timeline_name)

func _on_DialogEnd(_timeline_name: String, chang_hud_v: bool = true) -> void :
	dialog_active = false
	
	if chang_hud_v == true:
		set_visible_hud_elements(true)
	
	
	if dialogs_change_music == true:
		Audio.change_music_style("high")
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	get_tree().paused = false
	emit_signal("dialog_ended", _timeline_name)

func _on_DialogSignal(signal_name: String, dialog_name: String) -> void :
	emit_signal("dialog_signal_emitted", dialog_name, signal_name)

func _on_MainViewport_size_changed() -> void :
	
	
	if Config.get_value("video", "screen_scaling", false) == true or screen_scaling == true:
		var new_size: Vector2 = get_tree().get_root().size
		ViewPortGameScenario.size = new_size
		ViewPortGameScenario.set_size_override(true, Vector2(341, 192))
		ViewPortGameScenario.set_size_override_stretch(true)

func _on_TimerRecoverStamina_timeout() -> void :
	
	if VarsGlobal.game_data["player_sp_now"] < VarsGlobal.game_data["player_sp_max"]:
		
		var to_recover: int = 3
		
		var equip_bottom_ide: int = VarsGlobal.game_data["player_equip_3"][
			VarsGlobal.game_data["player_current_set"]
		]
		
		if equip_bottom_ide == GVar.EQUIPMENT.VIGOR_BOOTS:
			to_recover = 9999999
		
		VarsGlobal.game_data["player_sp_now"] = FuncsNumbers.add_value(
			to_recover, VarsGlobal.game_data["player_sp_now"], 
			VarsGlobal.game_data["player_sp_max"]
		)
		SPBar.value = VarsGlobal.game_data["player_sp_now"]
		SPBar.max_value = VarsGlobal.game_data["player_sp_max"]
	
	
	if FuncsNumbers.get_percentage(SPBar.value, SPBar.max_value) < 40.0:
		SPBar.modulate.a = 0.5
	else:
		SPBar.modulate.a = 1.0
	
	
	if VarsGlobal.game_data["player_sp_now"] == VarsGlobal.game_data["player_sp_max"]:
		TimerRecoverStamina.stop()

func _on_TimerRecoverMana_timeout() -> void :
	
	var equip_accesory_ide: int = VarsGlobal.game_data["player_equip_0"][
		VarsGlobal.game_data["player_current_set"]
	]
	var equip_top_ide: int = VarsGlobal.game_data["player_equip_1"][
		VarsGlobal.game_data["player_current_set"]
	]
	
	if VarsGlobal.game_data["player_mp_now"] < VarsGlobal.game_data["player_mp_max"]:
		
		var to_recover: int = 1
		
		
		if equip_accesory_ide == GVar.EQUIPMENT.SORCERER_RING:
			to_recover = 9999999999999
		elif equip_top_ide == GVar.EQUIPMENT.WITCH_HAT:
			to_recover = to_recover * 2
		
		VarsGlobal.game_data["player_mp_now"] = FuncsNumbers.add_value(
			to_recover, VarsGlobal.game_data["player_mp_now"], 
			VarsGlobal.game_data["player_mp_max"]
		)
		MPBar.value = VarsGlobal.game_data["player_mp_now"]
		MPBar.max_value = VarsGlobal.game_data["player_mp_max"]
		MPBarFull.visible = (MPBar.value == MPBar.max_value)
	
	
	if VarsGlobal.game_data["player_mp_now"] == VarsGlobal.game_data["player_mp_max"]:
		TimerRecoverMana.stop()

func _on_TimerReduceHPByPoison_timeout() -> void :
	
	if VarsGlobal.game_data["player_hp_now"] <= 1:
		return
	
	var damage_poison = int(VarsGlobal.game_data["player_hp_max"] * 0.05)
	
	VarsGlobal.Player.HurtBox.reduce_hp(damage_poison)
	
	
	
	if VarsGlobal.game_data["player_hp_now"] == 0:
		VarsGlobal.game_data["player_hp_now"] = 1
		
		

	update_hud_values(true)
	
	if VarsGlobal.game_data["player_poisoned"] == false:
		TimerReduceHPByPoison.stop()

func _on_TimerReduceMPByCurse_timeout() -> void :
	
	var reduce_mp = int(VarsGlobal.game_data["player_mp_max"] * 0.03)
	
	VarsGlobal.game_data["player_mp_now"] = FuncsNumbers.decrease_value(
		reduce_mp, VarsGlobal.game_data["player_mp_now"]
	)
	
	update_hud_values(false)
	
	if VarsGlobal.game_data["player_cursed"] == false:
		TimerReduceMPByCurse.stop()

func _on_TimerStartHPTween_timeout() -> void :
	
	TweenHPBar.interpolate_property(
		HPDamageBar, "value", HPDamageBar.value, HPBar.value, 2, 
		Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	TweenHPBar.start()

func _on_TimerStartRecoverStamina_timeout() -> void :
	
	if SPBar.value < SPBar.max_value:
		TimerRecoverStamina.start()

func _on_BtnPrevCircuitType_pressed() -> void :
	selected_type_circuit = FuncsArrays.get_new_position_on_array(
		selectable_type_circuits, selected_type_circuit, "prev"
	)
	
	if selected_type_circuit == 3:
		selected_type_circuit = 2
	get_node("%LblTypeCircuit").text = tr(selectable_type_circuits[selected_type_circuit])
	update_ui_circuit()
	update_alchemy_buttons()

func _on_BtnNextCircuitType_pressed() -> void :
	selected_type_circuit = FuncsArrays.get_new_position_on_array(
		selectable_type_circuits, selected_type_circuit, "next"
	)
	
	if selected_type_circuit == 3:
		selected_type_circuit = 0
	get_node("%LblTypeCircuit").text = tr(selectable_type_circuits[selected_type_circuit])
	update_ui_circuit()
	update_alchemy_buttons()

func _on_BtnAlchemy_focus_entered(type: int, item: int) -> void :
	Audio.play_sfx("ui_changed_value")
	
	
	if type in [0, 1, 3]:
		get_node("%BtnEquipCircuit").visible = true
	else:
		get_node("%BtnEquipCircuit").visible = false
		
		
		VarsGlobal.game_data[gamedata_ec_types[type]][
			VarsGlobal.game_data["player_current_set"]
		] = item
		
	
	get_node("%LblCircuitMPTIME").text = ""
	get_node("%LblCircuitDescription").text = ""
	
	get_node("%HBxAttrbPhysic").visible = false
	get_node("%HBxAttrbElement").visible = false
	
	
	match type:
		0:
			get_node("%UICircuit").action = - 1
			get_node("%UICircuit").ability = - 1
			get_node("%UICircuit").subweapon = - 1
			
			if item >= 0:
				get_node("%LblCircuitMPTIME").text = tr("QUANTITY") + ": %s" % [
					str(VarsGlobal.game_data["player_ec_alloy"][item]).pad_zeros(2)
				]
				
				get_node("%UICE_ALLOY").visible = true
				get_node("%UICE_ALLOY").frame = item
				
				
				get_node("%HBxAttrbElement").visible = true
				
				
				
				update_attrb_elemental_icons(Alloys.get_attrbs_elemental(item + 1))

			else:
				get_node("%UICE_ALLOY").visible = false
		1:
			get_node("%UICircuit").action = item
			if item >= 0:
				var action_time: int = ElementalCircuits.get_circuit_action_time(item)
				if action_time == - 1:
					get_node("%LblCircuitMPTIME").text = "MP: %s - (%s)." % [
						str(ElementalCircuits.get_circuit_mp_cost(type - 1, item)).pad_zeros(3), 
						tr("WHILECIRUITBTNPRESSED")
					]
				elif action_time == 0:
					get_node("%LblCircuitMPTIME").text = "MP: %s" % [
						str(ElementalCircuits.get_circuit_mp_cost(type - 1, item)).pad_zeros(3)
					]
				
				else:
					get_node("%LblCircuitMPTIME").text = "MP: %s - %s: %s %s" % [
						str(ElementalCircuits.get_circuit_mp_cost(type - 1, item)).pad_zeros(3), 
						tr("TIME"), 
						str(action_time), 
						tr("SCS")
					]
				
				get_node("%HBxAttrbElement").visible = true
				
				update_attrb_elemental_icons(ElementalCircuits.get_attrbs_elemental(item))
		2:
			get_node("%UICircuit").ability = item
			get_node("%LblCircuitMPTIME").text = ""
		3:
			get_node("%UICircuit").subweapon = item
			if item >= 0:
				get_node("%LblCircuitMPTIME").text = "MP: %s" % [
					str(ElementalCircuits.get_circuit_mp_cost(type - 1, item)).pad_zeros(2)
				]
				
				
	
	
	if item == - 1:
		
		match type:
			0:
				get_node("%LblCircuitDescription").text = tr("ABOUT_ALLOY")
			1:
				get_node("%LblCircuitDescription").text = tr("ABOUT_ACTION")
			2:
				get_node("%LblCircuitDescription").text = tr("ABOUT_ABILITY")
			3:
				get_node("%LblCircuitDescription").text = tr("ABOUT_SUBWEAPON")
	
	
	elif type == 0:
		get_node("%LblCircuitDescription").text = tr(GVar.ALLOYS.keys()[item + 1] + "_DESC")
	
	
	else:
		get_node("%LblCircuitDescription").text = tr(
			ElementalCircuits.get_circuit_string(type - 1, item) + "_DESC"
		)

func _on_BtnKeyObject_focus_entered(keyobject_ide: int) -> void :
	Audio.play_sfx("ui_changed_value")
	var object_string = GVar.KEYS_OBJECTS.keys()[keyobject_ide]
	
	get_node("%IconKeyObject").visible = true
	
	get_node("%SpriteKeyObject").frame = keyobject_ide
	
	get_node("%LblKeyObjTitle").text = tr(object_string + "_TITLE")
	if keyobject_ide == GVar.KEYS_OBJECTS.FIREPROOF_CONTAINER:
		get_node("%LblKeyObjDesc").text = tr(object_string + "_DESC") % [VarsGlobal.get_medallion_order()]
	else:
		get_node("%LblKeyObjDesc").text = tr(object_string + "_DESC")
	
	
	get_node("%ScrollContainerKeys").set_v_scroll(0)

	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	get_node("%HBxKeyScrollHelpers").visible = get_node("%ScrollContainerKeys").get_v_scrollbar().visible
	

func _on_BtnTreasure_focus_entered(treasure_ide: int) -> void :
	Audio.play_sfx("ui_changed_value")
	var object_string = GVar.TREASURES.keys()[treasure_ide]
	
	get_node("%IconTreasure").visible = true
	
	get_node("%SpriteTreasure").frame = treasure_ide
	
	get_node("%LblTreasureTitle").text = tr(object_string + "_TITLE")
	get_node("%LblKeyTreasureDesc").text = tr(object_string + "_DESC")
	
	if VarsGlobal.game_data["player_treasures"][treasure_ide] == true:
		get_node("%LblKeyTreasureDesc").text += " \n\n 》 " + tr("SOLD")

func _on_BtnNote_focus_entered(note_ide: int) -> void :
	Audio.play_sfx("paper_get")
	var object_string = GVar.NOTES.keys()[note_ide]
	
	if object_string == "ABOUT_NOTES":
		get_node("%LblNoteDesc").text = tr("EMPTY")
	else:
		get_node("%LblNoteDesc").text = tr(object_string + "_DESC")
	
	
	get_node("%ScrollContainerNote").set_v_scroll(0)

	get_node("%HBxTxtScrollHelpers").visible = false
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	get_node("%HBxTxtScrollHelpers").visible = get_node("%ScrollContainerNote").get_v_scrollbar().visible
	
func _BtnItemInventory_focus_entered(item_ide: int) -> void :
	Audio.play_sfx("ui_changed_value")
	update_inventory_data(item_ide)

func _on_EquipTabContainer_tab_changed(_tab: int) -> void :
	var current_tab = get_node("%EquipTabContainer").get_current_tab_control().name

	match current_tab:
		
		"INVENTORY":
			update_inventory_grid()
		
		"EQUIP":
			update_equip_buttons(selected_type_equip)

		"ALCHEMY":
			update_ui_circuit()
			update_alchemy_buttons()
			
			if Config.get_value("touch_screen_btn", "visible", false) == true:
				get_node("%BtnPrevCircuitType").self_modulate.a = 1
				get_node("%BtnPrevCircuitType").get_node("HelperIconBtn").visible = false
				get_node("%BtnNextCircuitType").self_modulate.a = 1
				get_node("%BtnNextCircuitType").get_node("HelperIconBtn").visible = false
			else:
				get_node("%BtnPrevCircuitType").self_modulate.a = 0
				get_node("%BtnPrevCircuitType").get_node("HelperIconBtn").visible = true
				get_node("%BtnNextCircuitType").self_modulate.a = 0
				get_node("%BtnNextCircuitType").get_node("HelperIconBtn").visible = true
		"OPTIONS":
			get_node("%VBxOptionsBtn").get_children()[0].grab_focus()
		"EXIT":
			get_node("%VbxExitButtons").get_children()[0].grab_focus()

func _on_MapTabContainer_tab_changed(_tab: int) -> void :
	var current_tab = get_node("%MapTabContainer").get_current_tab_control().name
	Audio.stop_sfx("ui_move_map")
	get_node("%PopupMarkerMenu").hide()
	
	match current_tab:
		
		"MAP":
			
			
			var vpad_visible: bool = Config.get_value(
				"touch_screen_btn", "visible", false
			)
			
			
			
			get_node("%MoveMapDpadA").visible = false
			get_node("%MoveMapDpadB").visible = false
			if vpad_visible == true:
				get_node("%MoveMapDpadB").visible = true
			else:
				get_node("%MoveMapDpadA").visible = true
		
			
			if Node2DMap.get_children().size() == 0:
				get_node("%MapPointer").visible = false
				get_node("%HBxMapActionsButtons/BtnCenterMap").visible = false
				get_node("%HBxMapActionsButtons/BtnAddMarkerMap").visible = false
				get_node("%HBxMapActionsButtons/BtnZoomMap").visible = false
			
			else:
				
				Audio.play_sfx("ui_center_map")
				Node2DMap.center()
				
			
			get_node("%LblPercentMap").text = "%.2f %%" % [
				VarsGlobal.get_map_percentage(VarsGlobal.game_data["visited_tiles"].size())
			]
			
			
			get_node("%LblAreaTitle").text = tr(VarsGlobal.game_data["current_area_title"])
			
			if get_node("%LblAreaTitle").text == VarsGlobal.game_data["current_area_title"]:
				get_node("%LblAreaTitle").text = get_node("%LblAreaTitle").text.capitalize()
		
		"KEYSOBJECTS":

			var VBxKeys: = get_node("%VBxKeysObjects")
			var keys_count: int = 0
			
			
			for btn in VBxKeys.get_children():
				btn.queue_free()

			for k in VarsGlobal.game_data["player_key_objects"]:
				var object_string = GVar.KEYS_OBJECTS.keys()[k]
				var ButtonInstance = Button.new()
				ButtonInstance.name = "BtnKObj-" + str(k)
				ButtonInstance.text = tr(object_string + "_TITLE")
				ButtonInstance.mouse_filter = Control.MOUSE_FILTER_PASS
				
				ButtonInstance.connect(
					"focus_entered", self, 
					"_on_BtnKeyObject_focus_entered", [k]
				)
				VBxKeys.add_child(ButtonInstance)
				
				if keys_count == 0:
					ButtonInstance.grab_focus()
				keys_count += 1
			
			
			if keys_count == 0:
				
				get_node("%IconKeyObject").visible = false
				
				get_node("%LblKeyObjTitle").text = tr("EMPTY_LIST")
				get_node("%LblKeyObjDesc").text = ""
		
		

		"TREASURES":
			var VBxTreasures: = get_node("%VBxTreasure")
			var treasures_count: int = 0
			
			
			for btn in VBxTreasures.get_children():
				btn.queue_free()

			for t in VarsGlobal.game_data["player_treasures"].keys():
				
				var object_string = GVar.TREASURES.keys()[t]
				var ButtonInstance = Button.new()
				ButtonInstance.name = "BtnTreasure-" + str(t)
				ButtonInstance.text = tr(object_string + "_TITLE")
				ButtonInstance.mouse_filter = Control.MOUSE_FILTER_PASS
				
				ButtonInstance.connect(
					"focus_entered", self, 
					"_on_BtnTreasure_focus_entered", [t]
				)
				VBxTreasures.add_child(ButtonInstance)
				
				if treasures_count == 0:
					ButtonInstance.grab_focus()
				treasures_count += 1
			
			
			
			if treasures_count == 0:
				
				get_node("%IconTreasure").visible = false
				
				get_node("%LblTreasureTitle").text = tr("EMPTY_LIST")
				get_node("%LblKeyTreasureDesc").text = ""
		
			

		"FINDINGS":
			var VBxNotes: = get_node("%VBxNotes")
			var notes_count: int = 0
			
			
			for btn in VBxNotes.get_children():
				btn.queue_free()
			var notes_collected: Array = VarsGlobal.game_data["player_notes"]
			
			var notes_collected_inverted: Array = notes_collected.duplicate()
			notes_collected_inverted.invert()
			
			for n in notes_collected_inverted:
				var object_string = GVar.NOTES.keys()[n]
				var ButtonInstance = Button.new()
				ButtonInstance.name = "BtnNote-" + str(n)
				ButtonInstance.text = tr(object_string + "_TITLE")
				ButtonInstance.mouse_filter = Control.MOUSE_FILTER_PASS
				
				ButtonInstance.connect(
					"focus_entered", self, 
					"_on_BtnNote_focus_entered", [n]
				)
				VBxNotes.add_child(ButtonInstance)
				
				ButtonInstance.focus_next = ButtonInstance.get_path()
				ButtonInstance.focus_previous = ButtonInstance.get_path()
				
				
				if notes_count == 0:
					ButtonInstance.grab_focus()
				notes_count += 1
				
			
			if notes_count == 0:
				get_node("%LblTxtListEmpty").visible = true
				get_node("%LblNoteDesc").text = ""
				get_node("%HBxTxtScrollHelpers").visible = false
			else:
				
				get_node("%LblTxtListEmpty").text = "-- * --"

	
	if current_tab == "MAP":
		get_node("%HBxMapActionsButtons").visible = true
		get_node("%HBxMapActionsButtons2").visible = false
	else:
		get_node("%HBxMapActionsButtons").visible = false
		get_node("%HBxMapActionsButtons2").visible = true

func _on_TimerRefreshAlchemyBtns_timeout() -> void :
	if get_node("%EquipTabContainer").get_current_tab_control().name == "ALCHEMY":
		yield(get_tree(), "idle_frame")
		get_node("%ScrollContainerAlchemyBtns").ensure_control_visible(get_focus_owner())

func _on_BtnUseItemInventory_pressed() -> void :
	
	var item_used: bool = true
	
	var focus_owner: Object = get_focus_owner()
	
	if focus_owner == null or get_node("%BtnUseItemInventory").disabled == true:
		return
	
	
	match focus_owner.item:
		
		
		GVar.INVENTORY_ITEM.POTION_HEALTH:
			if VarsGlobal.game_data["player_hp_now"] == VarsGlobal.game_data["player_hp_max"]:
				item_used = false
			else:
				var hp_recover: = int(
					float(VarsGlobal.game_data["player_hp_max"]) * 0.33
				)
				VarsGlobal.game_data["player_hp_now"] = FuncsNumbers.add_value(
					hp_recover, VarsGlobal.game_data["player_hp_now"], 
					VarsGlobal.game_data["player_hp_max"]
				)
		
		
		GVar.INVENTORY_ITEM.POTION_CURSE:
			if VarsGlobal.game_data["player_cursed"] == false:
				item_used = false
			else:
				TimerNoNegStatusCurse.start()
				VarsGlobal.game_data["player_cursed"] = false
		
		
		GVar.INVENTORY_ITEM.POTION_POISON:
			if VarsGlobal.game_data["player_poisoned"] == false:
				item_used = false
			else:
				TimerNoNegStatusPoison.start()
				VarsGlobal.game_data["player_poisoned"] = false
		
		
		GVar.INVENTORY_ITEM.FIRST_AID_KIT:
			if VarsGlobal.game_data["player_injured"] == false:
				item_used = false
			else:
				TimerNoNegStatusInjury.start()
				VarsGlobal.game_data["player_injured"] = false

		GVar.INVENTORY_ITEM.PAN:
			if VarsGlobal.game_data["player_hp_now"] == VarsGlobal.game_data["player_hp_max"]:
				item_used = false
			else:
				VarsGlobal.game_data["player_hp_now"] = FuncsNumbers.add_value(
					20, VarsGlobal.game_data["player_hp_now"], 
					VarsGlobal.game_data["player_hp_max"]
				)
		
		GVar.INVENTORY_ITEM.CHIKEN_LEG:
			if VarsGlobal.game_data["player_hp_now"] == VarsGlobal.game_data["player_hp_max"]:
				item_used = false
			else:
				VarsGlobal.game_data["player_hp_now"] = FuncsNumbers.add_value(
					40, VarsGlobal.game_data["player_hp_now"], 
					VarsGlobal.game_data["player_hp_max"]
				)
		GVar.INVENTORY_ITEM.ROTTEN_CHIKEN_LEG:
			VarsGlobal.game_data["player_hp_now"] = 1
		
		GVar.INVENTORY_ITEM.STINKING_FLESH:
			VarsGlobal.game_data["player_hp_now"] = 1
			
		GVar.INVENTORY_ITEM.BEER:
			if VarsGlobal.game_data["player_hp_now"] == VarsGlobal.game_data["player_hp_max"]:
				item_used = false
			else:
				VarsGlobal.game_data["player_hp_now"] = FuncsNumbers.add_value(
					80, VarsGlobal.game_data["player_hp_now"], 
					VarsGlobal.game_data["player_hp_max"]
				)
		
		GVar.INVENTORY_ITEM.POTION_MANA:
			if VarsGlobal.game_data["player_mp_now"] == VarsGlobal.game_data["player_mp_max"]:
				item_used = false
			else:
				VarsGlobal.game_data["player_mp_now"] = FuncsNumbers.add_value(
					30, VarsGlobal.game_data["player_mp_now"], 
					VarsGlobal.game_data["player_mp_max"]
				)
		
		GVar.INVENTORY_ITEM.CARPATITIA:
			if (
				VarsGlobal.Player.is_on_floor() == true
				and VarsGlobal.game_data["player_hp_now"] > 0
				and VarsGlobal.game_data["last_save_room_used"] != ""
				and VarsGlobal.GameScenario.boss_battle_active == false
				and can_use_carpatitia == true
			):
				
				pause_game()
				can_pause = false
				
				VarsGlobal.Player.set_enabled_input(false)
				VarsGlobal.Player.velocity.x = 0
				
				VarsGlobal.Player.invencibility(10, false)
				
				if VarsGlobal.game_data["player_hp_now"] > 0:
					
					VarsGlobal.current_room_changer = ""
					yield(get_tree().create_timer(0.5), "timeout")
					VarsGlobal.GameScenario.start_teleport()
			else:
				item_used = false
		GVar.INVENTORY_ITEM.CANDYDIFF:
			
			pause_game()
			can_pause = false
			
			VarsGlobal.Player.set_enabled_input(false)
			VarsGlobal.Player.velocity.x = 0
			
			VarsGlobal.Player.invencibility(3, false)
			show_flash()
			VarsGlobal.set_diff_stats(0)
			VarsGlobal.game_data["price_buy"] = 1.0
			Audio.play_sfx("chiptune_jingle")
			Audio.play_sfx("ui_achievement")
			yield(get_tree().create_timer(0.5), "timeout")
			VarsGlobal.Player.set_enabled_input(true)
			can_pause = true
			Notification.show_notif("DIFFCHANGEDTOEASY")
			VarsGlobal.game_data["player_inventory"][GVar.INVENTORY_ITEM.CANDYDIFF] = 0
		_:
			item_used = false
	
	
	if item_used == false:
		Audio.play_sfx("ui_incorrect")
		return
	
	Audio.play_sfx("ui_item_use")
		
	
	VarsGlobal.game_data["player_inventory"][focus_owner.item] -= 1
	
	update_stats_pause()
	update_hud_values(false)
	
	
	if VarsGlobal.game_data["player_inventory"][focus_owner.item] == 0:
		focus_owner.set_disabled(true)
	
	
	update_inventory_data(focus_owner.item)

func _on_BtnExit_pressed(quicksave: bool) -> void :
	
	Audio.play_sfx("ui_cancel")
	
	VarsGlobal.erase_flag("lux_tenebris_started", 1)
	
	if quicksave == true:
		if ThermalBar.is_active() == true:
			
			Audio.play_sfx("ui_not_enough_mana")
			return
		
		var err = Savedata.save_game(
			VarsGlobal.selected_slot, 
			VarsGlobal.selected_stage, 
			VarsGlobal.game_data["save_name"], 
			true
		)
		if err != OK:
			Notification.show_notif("Error with quicksave: " + str(err))
			return
	else:
		print_debug("salir sin guardar cambios")
	
	Audio.set_enabled_reverb(false)
	Audio.underwater_filter_enabled(false)
	Engine.time_scale = 1
	ThermalBar.stop()
	Stopwatch.stop()
	get_tree().paused = false
	emit_signal("game_exited")
	SceneChanger.change_scene("res://src/screens/main_menu.tscn")

func _on_BtnReturn_pressed() -> void :
	pause_game( - 1)

func _on_BtnCenterMap_pressed() -> void :
	Audio.play_sfx("ui_center_map")
	Node2DMap.center()

func _on_BtnZoomMap_pressed() -> void :
	Node2DMap.change_zoom()
	if Node2DMap.scale == Node2DMap.max_scale:
		get_node("%BtnZoomMap").text = tr("ZOOMOUT")
	else:
		get_node("%BtnZoomMap").text = tr("ZOOMIN")

func _on_BtnAddMarkerMap_pressed() -> void :
	Audio.play_sfx("ui_accept")
	
	
	for btn in get_node("%GridContainerMarkersButtons").get_children():
		var btn_name: String = btn.name
		var btn_marker_idx: int = int(btn_name.replace("Mark", ""))
		var marker_idx = Node2DMap.get_mark_idx(Node2DMap.get_pointed_tile())
		if marker_idx == - 1:
			get_node("%GridContainerMarkersButtons").get_children()[0].grab_focus()
			break
		elif marker_idx == btn_marker_idx:
			btn.grab_focus()
			break
	
	get_node("%PopupMarkerMenu").show()

func _on_BtnCloseMarkerMenu_pressed() -> void :
	get_node("%PopupMarkerMenu").hide()
	Audio.play_sfx("ui_cancel")

func _on_BtnSaveMarker_pressed() -> void :
	Audio.play_sfx("ui_put_object")
	
	
	var pointed_tile = Node2DMap.get_pointed_tile()
	var focus_owner_name: String = get_focus_owner().name
	var marker_ide: int = int(focus_owner_name.replace("Mark", ""))
	
	Node2DMap.add_mark(marker_ide, pointed_tile)
	
	get_node("%PopupMarkerMenu").hide()

func _on_BtnDeleteMarker_pressed() -> void :
	Audio.play_sfx("ui_put_object")

	var pointed_tile = Node2DMap.get_pointed_tile()

	
	
	if Node2DMap.get_mark_idx(pointed_tile) >= 0:
		
		Node2DMap.add_mark( - 1, pointed_tile)
	
	get_node("%PopupMarkerMenu").hide()

func _on_Tween_tween_completed(object: Object, key: NodePath) -> void :
	
	
	if object == BlackRect and key == ":modulate" and show_title == true:
		var area_title_translated: String = tr(VarsGlobal.game_data["current_area_title"])
		
		if area_title_translated == VarsGlobal.game_data["current_area_title"]:
			area_title_translated = VarsGlobal.game_data["current_area_title"].capitalize()
		
		
		if first_entry_area == true:
			VarsGlobal.game_data["visited_areas_title"].append(area_title)
			can_pause = false
			get_node("%DramaticTitle").show_title(area_title_translated)
		else:
			get_node("%AreaTitle").play(area_title_translated)
		

func _on_DramaticTitle_started() -> void :
	can_pause = false
	get_tree().paused = true

func _on_DramaticTitle_ended() -> void :
	can_pause = true
	get_tree().paused = false

func _on_Player_dead() -> void :
	get_tree().call_group("dialogic_dialognode", "queue_free")
	Engine.time_scale = 0.6
	Audio.stop_music()
	Audio.play_sfx("death_gingle")
	get_node("%AnimationPlayerDeath").play("show")
	
	
	if Config.get_value("gameplay", "show_death_counter", false) == true:
		get_node("%LblDeaths").visible = true
		get_node("%LblDeaths").text = "%d" % [
			VarsGlobal.game_data["total_deaths"]
		]
	else:
		get_node("%LblDeaths").visible = false
	
	
	Savedata.increase_death_counter()
	
	
	

func _on_AnimationPlayerDeath_animation_finished(
	_anim_name: String, use_carpatitia: bool = false
) -> void :
	
	Engine.time_scale = 1.0
	Audio.underwater_filter_enabled(false)

	VarsGlobal.current_room_changer = ""
	
	
	VarsGlobal.current_player_char = VarsGlobal.game_data["character"]
	
	
	if VarsGlobal.game_data["difficulty_base"] == 0:
		var items_hp: Array = [
			GVar.INVENTORY_ITEM.POTION_HEALTH, 
			GVar.INVENTORY_ITEM.BEER, 
			GVar.INVENTORY_ITEM.CHIKEN_LEG, 
			GVar.INVENTORY_ITEM.MELONPAN, 
			GVar.INVENTORY_ITEM.PAN
		]
		for it in items_hp:
			if VarsGlobal.has_item_inv(it) == true:
				
				VarsGlobal.respawned_savestatue_no_hp_item = true
	
	
	if Savedata.game_exists() == true:
		
		if use_carpatitia == false:
		
			Audio.play_sfx("ui_player_reborn")
			
			
			
			VarsGlobal.reset_data()
			
			
			Savedata.load_game()
			
			
			SceneChanger.change_scene(VarsGlobal.game_data["current_room_path"])
		
		
		elif can_use_carpatitia == true:
			Audio.play_sfx("ui_carpatitia_death_use")
			
			
			VarsGlobal.game_data["player_injured"] = false
			VarsGlobal.game_data["player_poisoned"] = false
			VarsGlobal.game_data["player_cursed"] = false
			
			VarsGlobal.game_data["player_hp_now"] = 1
			
			
			
			
			
			
			VarsGlobal.game_data["player_inventory"][
				GVar.INVENTORY_ITEM.CARPATITIA
			] -= 2
			
			SceneChanger.change_scene(
				VarsGlobal.game_data["last_save_room_used"]
			)
	
	
	else:
		SceneChanger.change_scene("res://src/screens/manage_savegame.tscn")

func _on_ButtonSwitchSet_set_changed(_current_set: int) -> void :
	emit_signal("set_changed")
	
	get_node("%ButtonSwitchSetAlchemy").refresh_letter()
	

	var current_tab = get_node("%EquipTabContainer").get_current_tab_control().name

	match current_tab:
		"ALCHEMY":
			update_ui_circuit()
			update_alchemy_buttons()
		"EQUIP":
			update_equip_buttons(selected_type_equip)

	update_hud_values(false)

func _on_BtnEquipType_pressed(type_select: int) -> void :
	update_equip_buttons(type_select)

func _on_BtnEquipItem_focus_entered(item_id: int) -> void :
	Audio.play_sfx("ui_changed_value")
	
	if item_id == - 1:
		get_node("%LblEquipItemDesc").text = ""
		get_node("%SpriteItemEquipIcon").visible = false
	else:
		get_node("%LblEquipItemDesc").text = GVar.EQUIPMENT.keys()[item_id + 1] + "_DESC"
		get_node("%SpriteItemEquipIcon").visible = true
		get_node("%SpriteItemEquipIcon").frame = item_id
	
	for stat in ["attack_power", "defense_rating", "int"]:
		
		var equiped_item: int = VarsGlobal.game_data["player_equip_" + str(selected_type_equip)][
			VarsGlobal.game_data["player_current_set"]
		]
		
		
		get_node("%Lbl_" + stat).text = "%s: %s" % [
			stat.to_upper(), VarsGlobal.get_stat(stat)
		]

		
		if VarsGlobal.get_stat(stat) < 0:
			get_node("%Lbl_" + stat).set("custom_colors/font_color", Color("fa8787"))
		
		elif VarsGlobal.get_stat(stat) > VarsGlobal.get_stat(stat, 0):
			get_node("%Lbl_" + stat).set("custom_colors/font_color", Color("87f0fa"))
		
		else:
			get_node("%Lbl_" + stat).set("custom_colors/font_color", Color("ffffff"))

		
		if (
			item_id == - 1 or equiped_item == item_id
		):
			
			if item_id == - 1 and equiped_item != - 1:
				
				var equip_item_data = CSVDBLoader.get_db("equipment_objects")[GVar.EQUIPMENT.keys()[equiped_item + 1]]
				var stat_total: int = VarsGlobal.get_stat(stat) - equip_item_data[stat]
				get_node("%LblEquipStat_" + stat).text = str(stat_total)
				
				if stat_total > VarsGlobal.get_stat(stat):
					get_node("%BuffIcon_" + stat).frame = 0
				elif stat_total < VarsGlobal.get_stat(stat):
					get_node("%BuffIcon_" + stat).frame = 1
				else:
					get_node("%BuffIcon_" + stat).frame = 2
					get_node("%LblEquipStat_" + stat).text = ""
			
			else:
				get_node("%LblEquipStat_" + stat).text = ""
				get_node("%BuffIcon_" + stat).frame = 2
		else:
			
			var equiped_item_data: Dictionary
			
			var equip_item_data = CSVDBLoader.get_db("equipment_objects")[GVar.EQUIPMENT.keys()[item_id + 1]]
			
			var stat_total: int = VarsGlobal.get_stat(stat)

			
			if equiped_item != - 1:
				equiped_item_data = CSVDBLoader.get_db("equipment_objects")[GVar.EQUIPMENT.keys()[equiped_item + 1]]
				stat_total = VarsGlobal.get_stat(stat) - equiped_item_data[stat]
			
			
			stat_total += equip_item_data[stat]
			
			
			get_node("%LblEquipStat_" + stat).text = str(stat_total)
			if stat_total > VarsGlobal.get_stat(stat):
				get_node("%BuffIcon_" + stat).frame = 0
			elif stat_total < VarsGlobal.get_stat(stat):
				get_node("%BuffIcon_" + stat).frame = 1
			else:
				get_node("%BuffIcon_" + stat).frame = 2
				get_node("%LblEquipStat_" + stat).text = ""

func _on_BtnEquipCircuit_pressed() -> void :
	var btn_focused = get_focus_owner()

	
	if btn_focused.type in [2]:
		Audio.play_sfx("ui_not_enough_mana")
		return

	Audio.play_sfx("ui_success")
	
	
	if btn_focused.type == 3:
		VarsGlobal.game_data[gamedata_ec_types[btn_focused.type]] = [
			btn_focused.ide, 
			btn_focused.ide, 
			btn_focused.ide, 
			btn_focused.ide
		]
		
		update_hud_switch_subweapon_icon()
	else:
		
		VarsGlobal.game_data[gamedata_ec_types[btn_focused.type]][
			VarsGlobal.game_data["player_current_set"]
		] = btn_focused.ide

	
	for b in get_node("%VBxAlchemyBtns").get_children():
		b.text = b.text.replace("=> ", "")
		
		if (
			b.ide == btn_focused.ide and 
			btn_focused.type in [0, 1, 3]
		):
			b.text = "=> " + b.text
	
	
	if gamedata_ec_types[btn_focused.type] == "player_ec_alloy_selected":
		emit_signal("alloy_changed")
	elif gamedata_ec_types[btn_focused.type] == "player_ec_action_selected":
		emit_signal("set_changed")
	

func _on_BtnEquipItem_pressed() -> void :
	
	var btn_focused = get_focus_owner()
	
	var equip_ide: int = int(btn_focused.editor_description)
	
	if equip_ide is int == false:
		Audio.play_sfx("ui_not_enough_mana")
		return
	
	Audio.play_sfx("ui_success")
	
	
	for n in range(4):
		VarsGlobal.game_data["player_equip_%d" % [selected_type_equip]][
			n
		] = equip_ide

	
	for b in get_node("%VBxEquipBtns").get_children():
		b.text = b.text.replace("=> ", "")
		if equip_ide == int(b.editor_description):
			b.text = "=> " + b.text
	
	
	var focused_button = get_focus_owner()
	self.focus_mode = Control.FOCUS_ALL
	self.grab_focus()
	focused_button.grab_focus()
	self.focus_mode = Control.FOCUS_NONE

func _on_LowHP_BloodLayoutAnim() -> void :
	if VarsGlobal.game_data["player_hp_now"] > 0:
		Audio.play_sfx("heartbeat")
		Gamepad.start_vibration(0, 0.4, 0.1, 0.3)

func _on_ThermalBar_started(_type: String) -> void :
	pass

func _on_ThermalBar_value_changed(val: int, type: String) -> void :
	
	if (
		ThermalBar.mode_stat == "minus" and ThermalBar.value == 0
		and VarsGlobal.GameScenario.thermal_condition == "none"
	):
		
		ThermalBar.stop()
		return
	
	if type == "heat":
		get_node("%ThermalBarHeat").visible = true
		get_node("%ThermalBarHeat").value = val
	elif type == "cold":
		get_node("%ThermalBarCold").visible = true
		get_node("%ThermalBarCold").value = val
	else:
		get_node("%ThermalBarUnderWater").visible = true
		get_node("%ThermalBarUnderWater").value = val
	
	
	
	
	if (
		ThermalBar.mode_stat == "add" and type in ["heat", "cold"]
	):
		var thermal_bar_threshold: bool = FuncsNumbers.get_percentage(
			ThermalBar.value, ThermalBar.max_value
		) > 50.0
		VarsGlobal.game_data["player_injured"] = thermal_bar_threshold
		update_hud_values(false)
	
	
	
	if type == "heat":
		get_node("%ThermalBarHeat/Icon").visible = ThermalBar.max_reached
	if type == "cold":
		get_node("%ThermalBarCold/Icon").visible = ThermalBar.max_reached
	else:
		get_node("%ThermalBarUnderWater/Icon").visible = ThermalBar.max_reached

func _on_ThermalBar_max_reached(type: String) -> void :
	if type == "heat":
		get_node("%ThermalBarHeat/Icon").visible = true
	if type == "cold":
		get_node("%ThermalBarCold/Icon").visible = true
	else:
		get_node("%ThermalBarUnderWater/Icon").visible = true

func _on_ThermalBar_stopped() -> void :
	get_node("%ThermalBarHeat").visible = false
	get_node("%ThermalBarHeat/Icon").visible = false
	get_node("%ThermalBarCold").visible = false
	get_node("%ThermalBarCold/Icon").visible = false
	get_node("%ThermalBarUnderWater").visible = false
	get_node("%ThermalBarUnderWater/Icon").visible = false

func _on_QuickMenu_set_changed() -> void :
	emit_signal("set_changed")

func _on_quick_text_ended(node_text: String) -> void :
	emit_signal("quick_text_ended", node_text)

func _can_pause_enabled(can_p: bool) -> void :
	can_pause = can_p
	set_visible_hud_elements(can_pause)

func _on_SwipeDetector_swipe_updated(partial_gesture) -> void :

	if CtrlMap.visible == true and partial_gesture.get_area().name == "Map":
		var current_tab = get_node("%MapTabContainer").get_current_tab_control().name
		if current_tab == "MAP":
			var popup_marker_visible: bool = get_node("%PopupMarkerMenu").visible
			if popup_marker_visible == false:
				match partial_gesture.get_direction():
					"up":
						Node2DMap.move(Vector2.UP)
					"down":
						Node2DMap.move(Vector2.DOWN)
					"left":
						Node2DMap.move(Vector2.LEFT)
					"right":
						Node2DMap.move(Vector2.RIGHT)
						Node2DMap.move(Vector2.RIGHT)

func _on_BtnContinueFromDeath_pressed() -> void :
	
	_on_AnimationPlayerDeath_animation_finished("", false)

func _on_BtnUseCarpatitiaDeath_pressed() -> void :
	_on_AnimationPlayerDeath_animation_finished("", true)

func _on_PopupMarkerMenu_visibility_changed() -> void :
	get_node("%DpadHelperMoveMap").visible = not get_node("%PopupMarkerMenu").visible

func _on_TimerRemovePoison_timeout() -> void :
	VarsGlobal.game_data["player_poisoned"] = false
	update_hud_values(false)
func _on_TimerRemoveInjury_timeout() -> void :
	VarsGlobal.game_data["player_injured"] = false
	update_hud_values(false)
func _on_TimerRemoveCurse_timeout() -> void :
	VarsGlobal.game_data["player_cursed"] = false
	update_hud_values(false)

func _on_VJoystickMap_stop_update_pos(_pos) -> void :
	for dir in ["left", "right", "up", "down"]:
		Input.action_release("ui_" + dir)

func _on_VJoystickMap_update_pos(pos) -> void :
	var dirs: Array = get_node("%VJoystickMap").get_dirs(pos)
	for dir in ["left", "right", "up", "down"]:
		if dir in dirs:
			Input.action_press("ui_" + dir)
		else:
			Input.action_release("ui_" + dir)

func _on_AudioHSlider_value_changed(value: float, key: String) -> void :
	
	Config.set_value("audio", key, value)
	get_node("CtrlPause/Equip/VBoxContainer/EquipTabContainer/OPTIONS/ScrollContainer/MarginContainer/VBxOptionsBtn/HBox_%s/LblNum" % [key]).text = String(int(value)).pad_zeros(0)
	Audio.play_sfx("ui_changed_value")

func _on_BtnShowMinimap_value_changed(_btn_name, _is_bool, value, section, key) -> void :
	Config.set_value(section, key, value)
	refresh_minimap_config()
func _on_BtnVisibilityMinimap_value_changed(_btn_name, _is_bool, value, section, key) -> void :
	Config.set_value(section, key, value)
	refresh_minimap_config()
func _on_BtnScreenFilter_value_changed(_btn_name, _is_bool, value, section, key) -> void :
	Config.set_value(section, key, value)
	update_vhs_setting()
	
