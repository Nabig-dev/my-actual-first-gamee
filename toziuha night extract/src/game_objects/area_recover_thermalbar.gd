extends Area2D

onready var TimerRecover = $TimerRecover


func _on_AreaRecoverThermal_body_entered(_body: Node) -> void :
	if (
		ThermalBar.is_active() == true
		or ThermalBar.max_reached == true
	):
		TimerRecover.start()


func _on_AreaRecoverThermal_body_exited(_body: Node) -> void :
	TimerRecover.stop()


func _on_TimerRecover_timeout() -> void :
	if (
		ThermalBar.is_active() == false
		and ThermalBar.max_reached == false
	):
		TimerRecover.stop()
		return
	
	ThermalBar.max_reached = false
	
	
	ThermalBar.reduce_bar(
		ThermalBar.max_value * 0.1
	)
