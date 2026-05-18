extends Control



var letter_lines: Array = [
	tr("ALESSALETTER1"), 
	tr("ALESSALETTER2"), 
	tr("ALESSALETTER3"), 
	tr("ALESSALETTER4"), 
	tr("ALESSALETTER5"), 
	tr("ALESSALETTER6"), 
	tr("ALESSALETTER7")
]
var current_line: int = 0

var _can_read: bool = true

func _ready() -> void :

	get_node("%HbxBtnNext").visible = false
	get_node("%Letter").modulate.a = 0
	
	yield(get_tree().create_timer(6), "timeout")
	
	var Tw: = get_tree().create_tween()
	
	Tw.tween_property(
		get_node("%Letter"), "modulate", Color.white, 2
	)
	yield(Tw, "finished")
	Audio.play_sfx("paper_get")
	set_text(0)
	get_node("%HbxBtnNext").visible = true

func _process(_delta: float) -> void :
	if (
		_can_read
		and Input.is_action_just_pressed("ui_accept")
		and get_node("%HbxBtnNext").visible == true
	):
		next_text()
	
	if _can_read and Input.is_action_just_pressed("ui_start"):
		_on_ButtonSkip_pressed()

func next_text() -> void :
	
	if get_node("%HbxBtnNext").visible == false:
		return
	
	current_line += 1
	if current_line > letter_lines.size() - 1:
		Audio.play_sfx("ui_accept")
		_on_letter_end()
	else:
		Audio.play_sfx("paper_get")
		get_node("%TimerCoolDown").start()
		get_node("%HbxBtnNext").visible = false
		set_text(current_line)

func set_text(line: int = 0) -> void :
	get_node("%LabelLetter").text = letter_lines[line]

func _on_letter_end() -> void :
	set_process(false)
	_can_read = false
	get_node("%HbxBtnNext").visible = false
	var Tw: = get_tree().create_tween()
	
	Tw.tween_property(
		get_node("%Letter"), "modulate", Color("00ffffff"), 1
	)
	yield(Tw, "finished")
	
	get_node("%HorsesScene").play_end()


func _on_TimerCoolDown_timeout() -> void :
	get_node("%HbxBtnNext").visible = true


func _on_ButtonSkip_pressed() -> void :
	_can_read = false
	set_process(false)
	SceneChanger.change_scene("res://stages/oota/grijayla/grijayla_entrance.tscn")
