extends Node2D

export var ide: String

func _ready() -> void :
	if ide.empty() == true:
		$InteractableArea2DIndicator.queue_free()
	else:
		if VarsGlobal.has_flag("stair" + ide) == true:
			$InteractableArea2DIndicator.queue_free()
			$AnimationPlayer.play("opened")

func snd() -> void :
	Audio.play_sfx("stair_mechanical")

func _on_InteractableArea2DIndicator_interact_requested() -> void :
	if VarsGlobal.Player.is_on_floor() == false:
		Audio.play_sfx("ui_incorrect")
	else:
		$InteractableArea2DIndicator.disconnect("interact_requested", self, "_on_InteractableArea2DIndicator_interact_requested")
		VarsGlobal.add_flag("stair" + ide)
		$AnimationPlayer.play("open")
		$InteractableArea2DIndicator.queue_free()
