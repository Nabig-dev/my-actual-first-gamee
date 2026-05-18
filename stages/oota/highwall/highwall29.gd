extends Node

func _on_RoomChanger3_player_positioned() -> void :
	$GameScenario / SkeletonWarrior.queue_free()
