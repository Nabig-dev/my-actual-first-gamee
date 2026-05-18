extends MarginContainer

var AchievCard = preload("res://src/ui_elements/button_achievement_card.tscn")

func _ready() -> void :
	
	
	
	var i: int = 0
	var achievs_total: int = Achievments.get_total_achievements()
	var achievs_unlocked_total: int = 0

	for achid in Achievments.achievs:
		var ObjInstance = AchievCard.instance()
		ObjInstance.achievement = achid
		if Achievments.is_ach_unlocked(achid):
			achievs_unlocked_total += 1
		ObjInstance.connect("focused", self, "_on_achiev_card_focused")
		get_node("%GridList").call_deferred("add_child", ObjInstance)
		
		if i == 0:
			yield(get_tree(), "idle_frame")
			ObjInstance.grab_focus()
		
		i += 1

	get_node("%LblCounter").text = "%d / %d" % [
		achievs_unlocked_total, achievs_total
	]
	
	if achievs_unlocked_total == achievs_total:
		get_node("%BtnReward").disabled = false
	else:
		get_node("%BtnReward").disabled = true

func _process(_delta: float) -> void :
	if Input.is_action_just_pressed("ui_cancel"):
		_on_BtnReturn_pressed()

func _on_achiev_card_focused(title: String, description: String) -> void :
	Audio.play_sfx("paper_get2")
	get_node("%LblTitle").text = title
	get_node("%LblDesc").text = description

func _on_BtnReturn_pressed() -> void :
	Audio.play_sfx("ui_cancel")
	SceneChanger.change_scene("res://src/screens/main_menu.tscn")

func _on_BtnReward_pressed() -> void :
	pass
