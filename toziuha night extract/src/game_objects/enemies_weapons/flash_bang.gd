extends Node2D

func _ready() -> void :
	$AnimationPlayer.play("show")

func flashbang() -> void :
	
	Audio.play_sfx("spell_prepare2")
	
	
	if (
		(
			global_position.x > VarsGlobal.Player.global_position.x
			and VarsGlobal.Player.facing == 1
		) or 
		(
			global_position.x < VarsGlobal.Player.global_position.x
			and VarsGlobal.Player.facing == - 1
		)
	):
		
		
		var img: = get_viewport().get_texture().get_data()
		img.flip_y()
		var textur: = ImageTexture.new()
		textur.create_from_image(img)
		$CanvasLayer / TextureRect.texture = textur
		
		Audio.play_sfx("ec_absorbed")
		$AnimationPlayer2.play("flash")
		return

	yield($AnimationPlayer, "animation_finished")
	queue_free()
