extends Node2D



var far_detected: int
var near_detected: int

func _check_exited() -> void :
	if (
		near_detected <= 0
		and far_detected > 0
	):
		$Geiger.play("low")
	
	elif (
		near_detected <= 0
		and far_detected <= 0
	):
		$Geiger.stop_all()
	
func _on_AreaFar_area_entered(area: Area2D) -> void :
	
	if area.is_weapon == true:
		return
	
	far_detected += 1
	if near_detected <= 0:
		$Geiger.play("low")

func _on_AreaFar_area_exited(area: Area2D) -> void :
	
	if area.is_weapon == true:
		return
	
	far_detected -= 1
	_check_exited()

func _on_AreaNear_area_entered(area: Area2D) -> void :
	if area.is_weapon == true:
		return
	$Geiger.play("high")
	near_detected += 1

func _on_AreaNear_area_exited(area: Area2D) -> void :
	if area.is_weapon == true:
		return
	near_detected -= 1
	_check_exited()


func _on_Geiger_tree_exiting() -> void :
	$Geiger.stop_all()
