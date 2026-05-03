extends RigidBody2D

signal obtained




export var ide: String

export (GVar.ALLOYS) var element = - 1

export var not_spawn_if_obtained: bool = true

func _ready() -> void :
	
	if (
		not_spawn_if_obtained == true and 
		(
			element == - 1
			or VarsGlobal.game_data["flags"].has(ide + "_alloy_obtained") == true
		)
	):
		queue_free()
		return
	
	$AlloysElements.frame = element


func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	
	var first_time: bool
	
	Audio.play_sfx("item_pickup")
	
	if VarsGlobal.game_data["flags"].has(ide + "_alloy_obtained") == false:
		VarsGlobal.game_data["flags"].append(ide + "_alloy_obtained")
	
	
	
	if VarsGlobal.game_data["player_ec_alloy"].keys().has(element) == false:
		VarsGlobal.game_data["player_ec_alloy"][element] = 1
		first_time = true
	
	
	else:
		VarsGlobal.game_data["player_ec_alloy"][element] += 1
	
	if first_time:
		
		visible = false
		VarsGlobal.Player.set_enabled_input(false)
		VarsGlobal.GameInterface.can_pause = false
		VarsGlobal.Player.stop_move()
		VarsGlobal.Player.invencibility(0.5, false)
		
		yield(get_tree().create_timer(0.5), "timeout")
		get_tree().paused = true
		
		var Dialog = Dialogic.start("")
		Dialog.dialog_node.dialog_script = {
			"events": [
				{
					"event_id": "dialogic_024", "set_theme": "theme-1677182817.cfg"
				}, 
				{
					"character": "", "event_id": "dialogic_001", "portrait": "", "text": "%s 》 [color=yellow]%s[/color]: %s" % [
						tr("ELEMENT"), 
						tr(GVar.ALLOYS.keys()[element + 1] + "_TITLE"), 
						tr(GVar.ALLOYS.keys()[element + 1] + "_DESC")
					]
				}
			]
		}
		VarsGlobal.GameInterface.add_child(Dialog)

		yield(Dialog, "timeline_end")
		yield(get_tree(), "idle_frame")
		VarsGlobal.Player.set_enabled_input(true)
		VarsGlobal.GameInterface.can_pause = true
		get_tree().paused = false
	
	else:
		VarsGlobal.GameInterface.show_notif_item_obtained(
			"%s: %s" % [
				tr("ELEMENT"), tr(GVar.ALLOYS.keys()[element + 1] + "_TITLE")
			]
		)
	
	emit_signal("obtained")

	queue_free()
