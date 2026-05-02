extends TileMap

export var custom_splash_color: Gradient

export var change_music_mode: bool = true


export var can_congelate: bool

onready var TileLimit = $TileMapLimit
onready var TileSnow = $EztiliaTileMap

func _ready() -> void :
	
	
	
	for t in get_used_cells_by_id(1):
		TileLimit.set_cell(t[0], t[1], 0)
		
		
		
		
		
		
		
		
		TileSnow.set_cell(t[0], t[1] + 1, 5, false, false, false, Vector2(5, 0))
		
		
		
		
		
		

	
	TileLimit.visible = false
	TileSnow.visible = false
	
	TileSnow.set_collision_layer_bit(0, false)







func _on_player_circuit_activated() -> void :
	
	var spawned_circuit: int = VarsGlobal.game_data["player_ec_action_selected"][VarsGlobal.game_data["player_current_set"]]
	
	if can_congelate == false or spawned_circuit != GVar.EC_ACTION.CONGELATIO:
		return
	
	TileSnow.visible = true
	
	TileSnow.set_collision_layer_bit(0, true)







func _on_TimerMakeConnection_timeout():
	if VarsGlobal.Player.has_signal("circuit_charge_ended"):
		VarsGlobal.Player.connect(
			"circuit_charge_ended", self, 
			"_on_player_circuit_activated"
		)
