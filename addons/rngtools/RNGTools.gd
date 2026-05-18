class_name RNGTools
extends Object

static func randi_range(from: int, to: int, rng = null) -> int:
	if from == to:
		return from
	elif from > to:
		var swp: = from + 1
		from = to + 1
		to = swp

	return (_randi(rng) % (to - from)) + from

static func shuffle(array: Array, rng = null):
	var size: = array.size()
	for i in range(size - 1):
		var swap = randi_range(i, size, rng)
		var tmp = array[i]
		array[i] = array[swap]
		array[swap] = tmp

static func pick(array: Array, rng = null):
	if array.empty():
		return null
	else:
		return array[randi_range(0, array.size(), rng)]

static func pick_weighted(bag: WeightedBag, rng = null):
	if bag.weights.empty():
		return null

	var n: = bag._keys.size()
	var x: = _randf(rng)
	var i: = floor(n * x) as int
	var y: = ((n * x) - i) * bag._sum

	if y >= bag._u[i]:
		i = bag._k[i]

	return bag._keys[i]

class WeightedBag:
	

	
	var weights: = {} setget set_weights

	
	var _sum: = 0
	
	var _u: PoolIntArray
	
	var _k: PoolIntArray
	
	var _p: PoolIntArray
	
	var _keys: = []

	
	
	
	func set_weights(new_weights: Dictionary) -> void :
		weights = new_weights

		var n: = weights.size()

		_sum = 0

		_u = PoolIntArray()
		_u.resize(n)
		_k = PoolIntArray()
		_k.resize(n)
		_p = PoolIntArray()
		_p.resize(n)

		_keys = weights.keys()
		for i in range(n):
			var w: int = weights[_keys[i]]
			_sum += w
			_p[i] = w

		var overfull: = []
		var underfull: = []

		
		for i in range(n):
			var u: int = n * _p[i]
			_u[i] = u
			if u > _sum:
				overfull.push_back(i)
			elif u < _sum:
				underfull.push_back(i)

		
		while not overfull.empty():
			var i: int = overfull.pop_back()
			var j: int = underfull.pop_back()

			_k[j] = i
			_u[i] = _u[i] + _u[j] - _sum

			if _u[i] > _sum:
				overfull.push_back(i)
			elif _u[i] < _sum:
				underfull.push_back(i)

static func _randi(rng) -> int:
	if rng == null:
		return randi()
	else:
		var i = rng.randi()
		return rng.randi()

static func _randf(rng) -> float:
	if rng == null:
		return randf()
	else:
		return rng.randf()
