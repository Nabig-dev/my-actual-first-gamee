extends RigidBody2D

signal obtained

export (
	GVar.TREASURES
) var item = 0

func _ready() -> void :
	
	
	if VarsGlobal.game_data["player_treasures"].keys().has(item):
		queue_free()
	
	$Sprite.frame = item

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	Audio.play_sfx("item_pickup")
	
	
	VarsGlobal.game_data["player_treasures"][item] = false
	
	VarsGlobal.GameInterface.show_notif_item_obtained(
		"%s: %s" % [
			tr("TREASURE"), tr(GVar.TREASURES.keys()[item] + "_TITLE")
		]
	)
	
	emit_signal("obtained")

	queue_free()
