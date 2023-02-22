import Structure from "./Structure.coffee"

export default class PolygonStructure extends Structure
	constructor: ->
		super() # calls @clear()
		# don't need to worry about calling onchange because can't be set at this point
	
	clear: ->
		super()
		@id_counter = 0
		@last_point_name = null
		@first_point_name = null
		@onchange?()
	
	toJSON: ->
		points: ({x, y} for point_name, {x, y} of @points)
	
	fromJSON: (def)->
		@points = {}
		@segments = {}
		@id_counter = 0
		@first_point_name = null
		@last_point_name = null
		for {x, y} in def.points
			@addVertex(x, y, false)
		@onchange?()
	
	addVertex: (x, y, changeEvent=true)->
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
		@onchange?() if changeEvent
	
	pointInPolygon: ({x, y})->
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
