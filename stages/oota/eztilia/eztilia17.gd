extends Node



func _on_RoomChanger5_player_positioned() -> void :
	$GameScenario / Bocuk.queue_free()
