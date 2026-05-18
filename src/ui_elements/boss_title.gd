extends Control

onready var Anim = $AnimationPlayer

func show_title(txt: String) -> void :
	
	get_node("%LblTitleBoss").text = txt
	

	Anim.play("show")
