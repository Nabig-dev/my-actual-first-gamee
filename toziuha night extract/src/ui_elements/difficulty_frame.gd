extends Node2D

export var diff: int = 0

func _ready() -> void :
	
	match diff:
		
		0:
			$BG.frame = 4
			$Char1.visible = true
			$Char2.visible = false
			$Char3.visible = false
			$Frame.frame = 0
		1:
			$BG.frame = 5
			$Char1.visible = false
			$Char2.visible = true
			$Char3.visible = false
			$Frame.frame = 1
		2:
			$BG.frame = 6
			$Char1.visible = false
			$Char2.visible = false
			$Char3.visible = true
			$Frame.frame = 2
		
			
