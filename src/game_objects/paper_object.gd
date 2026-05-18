extends RigidBody2D

signal obtained

export (GVar.NOTES) var text = 0
export (int, "paper", "parchment", "letter", "book") var type = 0

onready var Spr = $Sprite

func _ready() -> void :
	
	
	if VarsGlobal.game_data["player_notes"].has(text):
		queue_free()
	
	Spr.frame = type

func _on_AreaDetectPlayer_area_entered(_area: Area2D) -> void :
	Audio.play_sfx("paper_get")
	
	
	VarsGlobal.game_data["player_notes"].append(text)

	Notification.show_notif(
		tr("FINDINGS") + ": %s" % [
			tr(GVar.NOTES.keys()[text] + "_TITLE")
		]
	)
	
	emit_signal("obtained")
	
	queue_free()
