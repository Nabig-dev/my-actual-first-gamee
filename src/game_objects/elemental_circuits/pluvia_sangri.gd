extends CanvasLayer

var global_position: Vector2

onready var TimerActive = $TimerActive
onready var TimerApplyDamage = $TimerApplyDamage
onready var Anim = $AnimationPlayer
onready var Hitbox = $HitboxPlayer

var _enemies: Array

func _ready() -> void :
	
	
	
	var blood_percent: float = FuncsNumbers.get_percentage(
		VarsGlobal.game_data["player_bl_now"], 
		VarsGlobal.game_data["player_bl_max"]
	)
	var total_time: float = 8 * blood_percent / 100
	if total_time > 0.5:
		TimerActive.wait_time = total_time
	
	
	VarsGlobal.game_data["player_bl_now"] = FuncsNumbers.decrease_value(
		30, VarsGlobal.game_data["player_bl_now"]
	)
	VarsGlobal.GameInterface.update_hud_values()
	
	
	for e in get_tree().get_nodes_in_group("enemies"):
		var EnemNode: Object = e.get_node_or_null("EnemyBase")
		
		if EnemNode != null:
			_enemies.append(e)
			
			EnemNode.connect("enemy_defeated", self, "_on_EnemyDefeated")
	
	Anim.play("show")
	Audio.stop_sfx("rain", false)
	Audio.play_sfx("rain")
	Audio.play_sfx("thunder_0")

func _start_damage() -> void :
	TimerActive.start()
	TimerApplyDamage.start()

func get_visib_node(EnNode: Object) -> Object:
	var VisibNode: Object = EnNode.get_node_or_null("VisibilityEnabler2D")
	if VisibNode == null:
		VisibNode = EnNode.get_node_or_null("VisibilityNotifier2D")
	return VisibNode

func _on_EnemyDefeated(EnemyNode: Object) -> void :
	
	if VarsGlobal.game_data["player_bl_now"] >= 20:
		VarsGlobal.game_data["player_hp_now"] = FuncsNumbers.add_value(
			30, VarsGlobal.game_data["player_hp_now"], 
			VarsGlobal.game_data["player_hp_max"]
		)
		VarsGlobal.GameInterface.update_hud_values()
	_enemies.erase(EnemyNode)

func _on_AnimationPlayer_animation_started(anim_name: String) -> void :
	if anim_name == "hide":
		TimerApplyDamage.stop()

func _on_TimerActive_timeout() -> void :
	Audio.stop_sfx("ambient_rain", true, 2.0)
	Anim.play("hide")

func _on_TimerApplyDamage_timeout() -> void :
	for e in _enemies:
		var EnemyBase: Object = e.get_node("EnemyBase")
		var HurtboxEnemy: Object = EnemyBase.get_node_or_null(
			EnemyBase.hurtbox
		)
		var VisibNode: = get_visib_node(e)
		if VisibNode == null or (
			VisibNode != null and VisibNode.is_on_screen() == true
		):
			Hitbox.global_position = e.global_position
			HurtboxEnemy._on_HurtBoxEnemy_area_entered(Hitbox)

func _on_PluviaSangri_tree_exiting() -> void :
	if Audio.sfx_is_playing("rain") == true:
		Audio.stop_sfx("rain")
