
class @Structure
	constructor: ->
		@points = {}
		@segments = {}
	
	clear: ->
		@points = {}
		@segments = {}
	
	toJSON: ->
		{points} = @
		segments = {}
		for segment_name, segment of @segments
			segments[segment_name] = {}
			for k, v of segment when k not in ["a", "b"]
				segments[segment_name][k] = v
		{points, segments}
	
	fromJSON: (def)->
		@points = def.points
		@segments = {}
		for segment_name, seg_def of def.segments
			segment = {}
			segment[k] = v for k, v of seg_def
			segment.a = @points[segment.from]
			segment.b = @points[segment.to]
			@segments[segment_name] = segment
	
	setPose: (pose)->
		for point_name, point of pose.points
			# console.log point_name, point, @points[point_name]
			@points[point_name].x = point.x
			@points[point_name].y = point.y
	
	getPose: ->
		new Pose(@)
