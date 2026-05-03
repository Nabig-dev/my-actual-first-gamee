extends TextureButton

var TextureNormal = preload("res://assets/sprites/position_indicator_gray.png")
var TextureFocus = preload("res://assets/sprites/position_indicator.png")

export var scene_path: String

func _on_TextureButton_focus_entered() -> void :
	$Control / AnimationPlayer.play("focused")
	$Control / PositionIndicator.texture = TextureFocus


func _on_TextureButton_focus_exited() -> void :
	$Control / AnimationPlayer.play("RESET")
	$Control / PositionIndicator.texture = TextureNormal
