extends Node

var features_override: Array = [
	"pc", "early"
]

func has(feature: String) -> bool:
	if OS.has_feature("editor") == true:
		if feature in ["editor", "debug"]:
			return true
		else:
			return features_override.has(feature)
	else:
		return OS.has_feature(feature)
