import Structure from "./Structure.coffee"

export default class PolygonStructure extends Structure
	constructor: ->
		super() # calls @clear()
		# don't need to worry about calling onchange because can't be set at this point
		# but it is useful for the bounding box to be updated (via clear/signalChange/_update_bbox)
		# during construction.
	
	clear: ->
		super()
		@id_counter = 0
		@last_point_name = null
		@first_point_name = null
		@signalChange()
	
	signalChange: ->
		# API contract: bbox is updated before call to onchange
		@_update_bbox()
		@onchange?()

	toJSON: ->
		# Excluding segments, bbox_min/bbox_max, id_counter, first_point_name/last_point_name,
		# because they can all be derived from points.
		# (This class assumes the points/segments will not be renamed.)
		points: ({x, y} for point_name, {x, y} of @points)
	
	fromJSON: (def)->
		@points = {}
		@segments = {}
		@id_counter = 0
		@first_point_name = null
		@last_point_name = null
		for {x, y} in def.points
			@addVertex(x, y, false)
		@signalChange()
	
	addVertex: (x, y, registerChange=true)->
		from = @last_point_name
		name = ++@id_counter
		@first_point_name ?= name
		if @points[name]
			throw new Error "point/segment '#{name}' already exists adding vertex '#{name}'"
		@points[name] = {x, y, name}
		@last_point_name = name
		if @points[from]
			@segments[name] = {a: @points[from], b: @points[name]}
			@segments["closing"] = {a: @points[@last_point_name], b: @points[@first_point_name]}
		if registerChange
			@signalChange()
	
	_update_bbox: ->
		@bbox_min = {x: Infinity, y: Infinity}
		@bbox_max = {x: -Infinity, y: -Infinity}
		for point_name, point of @points
			@bbox_min.x = Math.min(@bbox_min.x, point.x)
			@bbox_min.y = Math.min(@bbox_min.y, point.y)
			@bbox_max.x = Math.max(@bbox_max.x, point.x)
			@bbox_max.y = Math.max(@bbox_max.y, point.y)
	
	pointInPolygon: ({x, y})->
		if x < @bbox_min.x or x > @bbox_max.x or y < @bbox_min.y or y > @bbox_max.y
			return false
		
		inside = no
		for segment_name, segment of @segments
			a_x = segment.a.x
			a_y = segment.a.y
			b_x = segment.b.x
			b_y = segment.b.y
			intersect =
				((a_y > y) isnt (b_y > y)) and
				(x < (b_x - a_x) * (y - a_y) / (b_y - a_y) + a_x)
			inside = not inside if intersect
		
		inside
