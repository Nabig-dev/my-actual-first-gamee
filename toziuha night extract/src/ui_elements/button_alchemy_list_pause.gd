extends Button


var ide: int = 0


var type: int = 0

func _ready() -> void :
	if ide == - 1:
		
		if type in [0, 1, 3]:
			text = tr("NONE")
		else:
			text = "- - - -"
		return
	
	match type:
		0:
			text = tr(GVar.ALLOYS.keys()[ide + 1] + "_TITLE")
		_:
			text = ElementalCircuits.get_circuit_string(
				type - 1, ide, true
			)
