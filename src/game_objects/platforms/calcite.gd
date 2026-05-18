extends StaticBody2D

signal impacted

onready var Spr = $Calcite
onready var HurtBox = $HurtboxEnemySimple
onready var Particle = $CPUParticles2D
onready var TimerQueue = $TimerQueue
onready var Collision = $CollisionShape2D

func _on_HurtboxEnemySimple_area_entered(area: Area2D) -> void :
	var alloy_equiped: int = VarsGlobal.game_data["player_ec_alloy_selected"][
		VarsGlobal.game_data["player_current_set"]
	]
	
	if area.identifier.begins_with("whip") and alloy_equiped == GVar.ALLOYS.C:
		Audio.play_sfx("impact_mineral")
		Spr.visible = false
		HurtBox.set_deferred("monitoring", false)
		Collision.set_deferred("disabled", true)
		Particle.emitting = true
		TimerQueue.start()

func _on_TimerQueue_timeout() -> void :
	queue_free()

func _on_HurtboxEnemySimple_damaged() -> void :
	emit_signal("impacted")
