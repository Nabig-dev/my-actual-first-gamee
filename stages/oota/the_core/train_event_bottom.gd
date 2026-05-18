extends Node

func _ready() -> void :
	yield(get_tree().create_timer(0.3), "timeout")
	VarsGlobal.GameInterface.connect(
		"dialog_signal_emitted", self, "_on_dialogsignal"
	)

func _on_dialogsignal(_dialogname: String, _signalname: String) -> void :
	SceneChanger.change_scene("res://stages/oota/the_core/train_event_1.tscn")

func _on_InteractableArea2DIndicator_interact_requested() -> void :
	VarsGlobal.GameInterface.start_dialog("return-start-train")
