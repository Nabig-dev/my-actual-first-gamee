extends Node2D

func _ready() -> void :
	$AnimatedSprite.play("default")
	$CPUParticles2D.emitting = true
	

func _started_reaction(type: String) -> void :
	$AreaDetectPlayerWeaponAttrbs.disconnect(
		"attr_detected", self, 
		"_on_AreaDetectPlayerWeaponAttrbs_attr_detected"
	)
	match type:
		"pyro":
			Audio.play_sfx("explosion_clean")

func _on_Timer_timeout() -> void :
	queue_free()

func _on_AreaDetectPlayerWeaponAttrbs_attr_detected(attrb_elemental: Array) -> void :
	if attrb_elemental.has("pyro") == true:
		$AnimationPlayer.play("explode")

func _on_TimerEnableDetect_timeout() -> void :
	
	pass
