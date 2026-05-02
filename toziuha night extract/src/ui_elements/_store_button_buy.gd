extends MarginContainer

var ide: int
var title: String

var price: int

var desc: String

var type: String

func set_data(dat: Dictionary) -> void :
	
	ide = dat["ide"]
	type = dat["type"]
	title = dat["name"]
	price = dat["price"]
	desc = dat["desc"]
	$Button.text = dat["name"]
