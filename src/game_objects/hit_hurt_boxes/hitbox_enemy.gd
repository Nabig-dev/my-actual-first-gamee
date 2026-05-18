extends Area2D

export var identifier: String = "missingno"

export var hurtbox_node: NodePath

export var is_weapon: bool

export var knockback_ultra: bool

export var poison: bool
export var curse: bool
export var injury: bool

func _ready() -> void :
	if hurtbox_node.is_empty() == false:
		
		get_node(hurtbox_node).connect("defeated", self, "_on_enemy_defeated")

func _on_enemy_defeated() -> void :
	set_deferred("monitorable", false)
