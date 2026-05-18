extends Node2D

var dir: int = 1

func _ready() -> void :
	
	ElementalCircuits.apply_mana_cost(
		GVar.EC_MODE.SUBWEAPON, 
		GVar.EC_SUBWEAPON.LANCEA_ARGENTEA
	)
	
	$GhostTrail.start_trail()
	$EcLanceaArgentea.scale.x = dir

func _process(delta: float) -> void :
	global_position.y -= 230 * delta
	global_position.x += (320 * dir) * delta

func _on_VisibilityNotifier2D_screen_exited() -> void :
	queue_free()
