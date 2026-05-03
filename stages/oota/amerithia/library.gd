extends Node

var reading: bool = false

var entries: Array = [
	"BAKDASHONATK", "NEGATIVESTATUS", 
	"THERMALRESIS", "ABOUTDAMAGEINFLICT", 
	"RESISTANDWEAKNS", "ABOUTMULTIPLEEQUIP"
]

func _ready() -> void :
	
	get_node("%ScrEntries").visible = false
	get_node("%CtrlTextEntry").visible = false
	
	var i: int = 0
	for en in entries:
		var Btn: = Button.new()
		Btn.connect("pressed", self, "_on_BtnEntry", [i])
		Btn.text = tr(en)
		
		get_node("%Hflow").add_child(Btn)
		
		i += 1

func _process(_delta: float) -> void :
	
	if reading == false:
		return
	
	if (
		get_node("%CtrlTextEntry").visible == false
		and Input.is_action_just_pressed("ui_cancel")
	):
		close_entry_scr()
	elif (
		get_node("%CtrlTextEntry").visible == true
		and Input.is_action_just_pressed("ui_cancel")
	):
		close_entry()

func open_entry_scr() -> void :
	Audio.play_sfx("ui_success")
	reading = true
	get_node("%Hflow").get_children()[0].grab_focus()
	get_node("%ScrEntries").visible = true

func close_entry_scr() -> void :
	Audio.play_sfx("ui_cancel")
	reading = false
	get_node("%ScrEntries").visible = false
	VarsGlobal.GameInterface.can_pause = true
	VarsGlobal.Player.set_enabled_input(true)

func open_entry(idx: int) -> void :
	
	if get_node("%CtrlTextEntry").visible == true:
		return
	
	Audio.play_sfx("ui_accept")
	
	var ctrols_text_children: Array = get_node("%CtrolsText").get_children()
	
	get_node("%CtrlTextEntry").visible = true
	get_node("%LblTitleText").text = tr(entries[idx])

	for n in ctrols_text_children:
		n.visible = false
	ctrols_text_children[idx].visible = true

func close_entry() -> void :
	Audio.play_sfx("ui_cancel")
	get_node("%CtrlTextEntry").visible = false

func _on_BtnEntry(_idx: int) -> void :
	open_entry(_idx)

func _on_BtnCloseScrEntries_pressed() -> void :
	close_entry_scr()
func _on_BtnCloseEntry_pressed() -> void :
	close_entry()


func _on_InteractableArea2DIndicator_interact_requested() -> void :
	if reading == true:
		return
	reading = true
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.Player.stop_move()
	yield(get_tree().create_timer(0.5), "timeout")
	open_entry_scr()
