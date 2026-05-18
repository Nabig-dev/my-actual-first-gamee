extends VisibilityNotifier2D

onready var Zombie = preload("res://src/game_objects/enemies/zombie.tscn")
onready var Zombie0 = preload("res://src/game_objects/enemies/zombie0.tscn")

export var zombie_type: String = "zombie"
export var active: bool = true
export var time_spawn: int = 5
export var max_spawns: int = 5

var positions_spawn: Array

var _total_spawned: int

onready var TimerSpawn = $TimerSpawn

func _ready() -> void :
	for n in get_children():
		if n is Position2D:
			var VisNotif = VisibilityNotifier2D.new()
			VisNotif.name = "VisNotif"
			n.add_child(VisNotif)
			positions_spawn.append(n)

func spawn() -> void :
	
	if active == false or (
		positions_spawn.empty() == true
		or is_on_screen() == false
		or _total_spawned >= max_spawns
	):
		return
	
	randomize()
	var randint: int = randi() % positions_spawn.size()
	
	
	if positions_spawn[randint].get_node("VisNotif").is_on_screen() == false:
		TimerSpawn.start(0.1)
		return
	
	var ObjInstance: Object
	
	match zombie_type:
		"zombie":
			ObjInstance = Zombie.instance()
		"zombie0":
			ObjInstance = Zombie0.instance()
	
	ObjInstance.global_position = positions_spawn[randint].global_position

	ObjInstance.get_node("HurtboxEnemy").connect("defeated", self, "_on_EnemyDefeated")
	
	VarsGlobal.GameScenario.call_deferred("add_child", ObjInstance)
	
	_total_spawned += 1

func _on_EnemyDefeated() -> void :
	_total_spawned -= 1

func _on_TimerSpawn_timeout() -> void :
	spawn()
	randomize()
	TimerSpawn.start(
		randi() % time_spawn + 1
	)
