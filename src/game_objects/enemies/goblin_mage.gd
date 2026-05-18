extends RigidBody2D

var LightOrbs = preload("res://src/game_objects/enemies_weapons/magic_orb_light_goblin_mage.tscn")
var Thunder = preload("res://src/game_objects/enemies_weapons/thunder_goblin_ray.tscn")

onready var Enemy = $EnemyBase
onready var VisibNotif = $VisibilityNotifierCameraArea

func _ready() -> void :
	Enemy.change_state("idle", true)

func prepare_snd() -> void :
	Audio.play_sfx("spell_prepare")

func spawn_atk() -> void :
	Enemy.change_direction("to_player")
	var ObjInstance = LightOrbs.instance()
	ObjInstance.add_to_group("goblin_mage_%d" % [get_instance_id()])
	ObjInstance.global_position = $Sprite / Flare.global_position
	ObjInstance.dir = Enemy.facing
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	Audio.play_sfx("spell_shoot")

func spawn_thunder() -> void :
	Enemy.change_direction("to_player")
	var ObjInstance = Thunder.instance()
	ObjInstance.global_position = VarsGlobal.Player.global_position
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)

func _on_TimerMakeAtk_timeout() -> void :
	
	if VisibNotif.is_on_screen() == false:
		$TimerMakeAtk.start(1)
		return
	
	randomize()

	if Enemy.state == "idle":
		Enemy.change_direction("to_player")
		
		if get_tree().get_nodes_in_group(
			"goblin_mage_%d" % [get_instance_id()]
		).size() > 0:
			Enemy.change_state("thunder")
			Enemy.state = "attack"
		else:
			Enemy.change_state("attack")
		
		Audio.play_sfx("goblin_laugh")
	
	elif Enemy.state == "attack":
		Enemy.change_direction("to_player")
		Enemy.change_state("idle")
		$TimerMakeAtk.start(rand_range(1, 2))

func _on_HurtboxEnemy_defeated() -> void :
	Audio.stop_sfx("goblin_laugh")
