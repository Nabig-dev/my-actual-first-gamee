tool 
extends Node2D

export var active: bool = true

signal player_entered

export var one_shot: bool

export (Array, NodePath) var spike_blocks: Array = []
export var snow: bool = false setget set_snow

func _ready() -> void :
	if Engine.is_editor_hint() == false:
		
		for block in spike_blocks:
			if block.is_empty() == false:
				
				connect(
					"player_entered", 
					get_node(block), 
					"start_spawn_arrow"
				)
		
		if active == false:
			$StaticBody2D.position.y = 2

func set_snow(snw: bool) -> void :
	snow = snw
	$StaticBody2D / Platform.visible = not snow
	$StaticBody2D / PlatformSnow.visible = snow

func _on_AreaDetectPlayer_body_entered(_body: Node) -> void :
	
	if active == false:
		return
	
	if $AreaDetectPlayer.is_connected(
		"body_exited", self, "_on_AreaDetectPlayer_body_exited"
	) == false:
		return
	
	if VarsGlobal.Player.global_position.y > global_position.y:
		return
	
	$StaticBody2D.position.y = 2
	if snow == true:
		$ParticlesSnow.emitting = true
	emit_signal("player_entered")

	if one_shot == true:
		$AreaDetectPlayer.disconnect("body_exited", self, "_on_AreaDetectPlayer_body_exited")

func _on_AreaDetectPlayer_body_exited(_body: Node) -> void :
	if active == false:
		return
	$StaticBody2D.position.y = 0
