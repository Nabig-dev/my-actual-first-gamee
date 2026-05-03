extends Button

signal focused(title, description)

var achievement: String = "ach1"
var data: Dictionary

func _ready() -> void :

	data = Achievments.get_ach_data(achievement)
	
	if Achievments.is_ach_unlocked(achievement):
		disabled = false
		get_node("%Image").texture = load(data["imgpath"])
	else:
		disabled = true
		get_node("%Image").texture = load(data["imgpath_locked"])

func _on_ButtonAchievementCard_focus_entered() -> void :
	emit_signal("focused", data["name"], data["desc"])
