tool 

extends Node2D

export var cut_sprite: bool setget update_sprite

func update_sprite(cut: bool) -> void :
	cut_sprite = cut
	if cut_sprite == true:
		$SpikesA2.visible = true
		$SpikesA.visible = false
	else:
		$SpikesA2.visible = false
		$SpikesA.visible = true
