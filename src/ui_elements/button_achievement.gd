extends Button

export var is_for_notif: bool

var achievement: String = "ach1"

func _ready() -> void :

	var data: Dictionary = Achievments.get_ach_data(achievement)
	
	get_node("%LblTitle").text = data["name"]
	get_node("%LblDesc").text = data["desc"]
	
	if Achievments.is_ach_unlocked(achievement):
		disabled = false
		get_node("%Image").texture = load(data["imgpath"])
	else:
		disabled = true
		get_node("%Image").texture = load(data["imgpath_locked"])

	if is_for_notif == true:
		focus_mode = Control.FOCUS_NONE
