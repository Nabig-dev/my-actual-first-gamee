extends Node

export var destination_l: String
export var destination_r: String

func _ready() -> void :
	$GameScenario / RoomChangerL.path_destination = destination_l
	$GameScenario / RoomChangerR.path_destination = destination_r
