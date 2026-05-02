extends Control

func show_notif(id_achievement: String) -> void :
	var data: Dictionary = Achievments.get_ach_data(id_achievement)
	get_node("%LblTitle").text = data["name"]
	get_node("%IconAchievement").texture = load(data["imgpath"])
	$AnimationPlayer.play("show")
