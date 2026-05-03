extends RigidBody2D

signal obtained




export var ide: String

export (GVar.EQUIPMENT) var item = - 1

export var not_spawn_if_obtained: bool = true

func _ready() -> void :
	
	if (
		not_spawn_if_obtained == true and 
		(
			item == - 1
			or VarsGlobal.game_data["flags"].has(ide + "_equipment_obtained") == true
		)
	):
		queue_free()
		return
	
	$Sprite.frame = item


func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	
	Audio.play_sfx("item_pickup")
	


	
	VarsGlobal.game_data["player_equip_items"].append(item)
	
	if VarsGlobal.game_data["flags"].has(ide + "_equipment_obtained") == false:
		VarsGlobal.game_data["flags"].append(ide + "_equipment_obtained")
	
	Notification.show_notif(
		"%s" % [
			tr(GVar.EQUIPMENT.keys()[item + 1] + "_TITLE")
		]
	)
	
	emit_signal("obtained")

	queue_free()
