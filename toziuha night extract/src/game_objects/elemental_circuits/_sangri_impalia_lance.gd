extends Node2D

signal impacted_enemy

func _on_HitboxPlayer_area_entered(_area: Area2D) -> void :
	emit_signal("impacted_enemy")
