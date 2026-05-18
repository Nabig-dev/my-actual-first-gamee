extends Node

func _on_RoomChanger2_player_positioned() -> void :
	$GameScenario / Golum.queue_free()
