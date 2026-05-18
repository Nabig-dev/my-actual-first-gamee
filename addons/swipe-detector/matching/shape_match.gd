extends "gesture_match.gd"

const ShapeSimilarityAlgorithm = preload("shape_similarity_algorithm.gd")

func _init(sample, pattern, threshold).(sample, pattern, threshold):
	pass

func similarity_algorithm():
	return ShapeSimilarityAlgorithm.new()

func points(gesture):
	return gesture.get_points()