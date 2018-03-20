
@[k] = Math[k] for k in Object.getOwnPropertyNames(Math)
@TAU = PI * 2

# hope we never want to use Euler's number
@E = ReactScript

distanceSquared = (v, w)-> (v.x - w.x) ** 2 + (v.y - w.y) ** 2
@distance = (v, w)-> sqrt(distanceSquared(v, w))

distanceToLineSegmentSquared = (p, v, w)->
	l2 = distanceSquared(v, w)
	return distanceSquared(p, v) if l2 is 0
	t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2
	t = max(0, min(1, t))
	distanceSquared(p, {
		x: v.x + t * (w.x - v.x)
		y: v.y + t * (w.y - v.y)
	})
@distanceToLineSegment = (p, v, w)->
	sqrt(distanceToLineSegmentSquared(p, v, w))

@lineSegmentsIntersect = (x1, y1, x2, y2, x3, y3, x4, y4)->
	a_dx = x2 - x1
	a_dy = y2 - y1
	b_dx = x4 - x3
	b_dy = y4 - y3
	s = (-a_dy * (x1 - x3) + a_dx * (y1 - y3)) / (-b_dx * a_dy + a_dx * b_dy)
	t = (+b_dx * (y1 - y3) - b_dy * (x1 - x3)) / (-b_dx * a_dy + a_dx * b_dy)
	(0 <= s <= 1 and 0 <= t <= 1)

@lerpPoints = (a, b, b_ness)->
	result = {}
	for k, v of a
		if typeof v is "number"
			result[k] = v + (b[k] - v) * b_ness
		else
			result[k] = v
	result

@entity_classes = {}
@addEntityClass = (constructor)->
	entity_classes[constructor.name] = constructor

@rename_object_key = (object, old_key, new_key)->
	new_object = {}
	for k, v of object
		if k is old_key
			new_object[new_key] = v
		else
			new_object[k] = v
	# return new_object
	for k, v of object
		delete object[k]
	for k, v of new_object
		object[k] = v
