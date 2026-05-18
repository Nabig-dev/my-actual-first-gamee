extends Node














signal started(type)
signal value_changed(val, type)
signal max_reached(type)
signal stopped

var value: int = 0
var max_value: int = 100

var max_reached: bool = false



var mode_stat = "add"


var type: String = "none"

onready var TimerAddStat = $TimerAddStat


func is_active() -> bool:
	return not TimerAddStat.is_stopped()



func start(t: String = "heat", initial_value: int = 0) -> void :
	
	var obtained_undina: bool = ElementalCircuits.was_obtained(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.AMPHIBIOUS_BREATHING
	)

	
	
	if t == "underwater" and obtained_undina == true:
		return
	
	
	if t != type:
		value = initial_value
	max_reached = false
	mode_stat = "add"
	type = t
	TimerAddStat.start()
	emit_signal("started", type)

func reset() -> void :
	type = "none"
	value = 0
	max_reached = false
	TimerAddStat.stop()

func stop() -> void :
	reset()
	emit_signal("stopped")

func reduce_bar(val: int) -> void :
	if type != "none" and max_reached == false:
		
		value = FuncsNumbers.decrease_value(
			val, value
		)
		emit_signal("value_changed", value, type)


func _on_TimerAddStat_timeout() -> void :
	
	if type == "none":
		return
	
	var obtained_undina: bool = ElementalCircuits.was_obtained(
		GVar.EC_MODE.ABILITY, GVar.EC_ABILITY.AMPHIBIOUS_BREATHING
	)

	
	if mode_stat == "add":
		if value < max_value:
			if type == "underwater":
				if obtained_undina == false:
					value += 5
			else:
				value += 1
		
		else:
			VarsGlobal.Player.HurtBox.reduce_hp(int(
				VarsGlobal.game_data["player_hp_max"] * 0.05
			))
			if VarsGlobal.game_data["player_hp_now"] == 0 and VarsGlobal.Player.has_method("death"):
				VarsGlobal.Player.death()
			VarsGlobal.GameInterface.update_hud_values()
	
	
	elif mode_stat == "minus" and value > 0:
		
		value = FuncsNumbers.decrease_value(
			3, value
		)
		max_reached = false
		
	
	if value >= max_value and max_reached == false and mode_stat == "add":
		max_reached = true
		emit_signal("max_reached", type)
	
	emit_signal("value_changed", value, type)
