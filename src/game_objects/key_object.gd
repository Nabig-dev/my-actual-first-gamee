extends RigidBody2D

signal obtained

export (
	GVar.KEYS_OBJECTS
) var item = GVar.KEYS_OBJECTS.BRONZE_KEY

onready var Spr = $Sprite

func _ready() -> void :
	
	
	if VarsGlobal.game_data["player_key_objects"].has(item):
		queue_free()
	
	Spr.frame = item

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	Audio.play_sfx("item_pickup")
	
	
	VarsGlobal.game_data["player_key_objects"].append(item)
	
	var order_medallions: String
	
	
	if item == GVar.KEYS_OBJECTS.FIREPROOF_CONTAINER:
		randomize()
		var elements: Array = ["H", "Fe", "S", "N", "Cl", "Si", "O"]
		
		elements = FuncsArrays.shuffle_array_with_seed(elements, VarsGlobal.game_data["save_name"])
		for e in elements:
			order_medallions = order_medallions + e + "."
		order_medallions = order_medallions.trim_suffix(".")
		VarsGlobal.add_flag("medallion_order_" + order_medallions)

	visible = false
	
	VarsGlobal.Player.set_enabled_input(false)
	VarsGlobal.GameInterface.can_pause = false
	VarsGlobal.Player.stop_move()
	VarsGlobal.Player.invencibility(0.5, false)
	
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().paused = true
	
	var Dialog = Dialogic.start("")
	var item_description: String
	
	if item == GVar.KEYS_OBJECTS.FIREPROOF_CONTAINER:
		item_description = tr(GVar.KEYS_OBJECTS.keys()[item] + "_DESC") % [order_medallions]
	else:
		item_description = tr(GVar.KEYS_OBJECTS.keys()[item] + "_DESC")
	
	Dialog.dialog_node.dialog_script = {
		"events": [
			{
				"event_id": "dialogic_024", "set_theme": "theme-1677182817.cfg"
			}, 
			{
				"character": "", "event_id": "dialogic_001", "portrait": "", "text": "%s 》 [color=yellow]%s[/color]: %s" % [
					tr("OBJECT_KEY"), 
					tr(GVar.KEYS_OBJECTS.keys()[item] + "_TITLE"), 
					item_description
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
	
	emit_signal("obtained")
	
	queue_free()
