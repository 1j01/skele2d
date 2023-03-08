import PolygonStructure from "./structure/PolygonStructure.coffee"

export run_tool = (tool, editing_entity, mouse_in_world, mouse_world_delta_x, mouse_world_delta_y, brush_size)->
	local_mouse_position = editing_entity.fromWorld(mouse_in_world)

	indices_within_radius = []
	for point_name, point of editing_entity.structure.points
		dx = point.x - local_mouse_position.x
		dy = point.y - local_mouse_position.y
		dist_squared = dx*dx + dy*dy
		dist = Math.sqrt(dist_squared)
		if dist < brush_size
			switch tool
				when "sculpt"
					point.x += mouse_world_delta_x / Math.max(1200, dist_squared) * 500
					point.y += mouse_world_delta_y / Math.max(1200, dist_squared) * 500
				when "roughen"
					point.x += (Math.random() - 0.5) * brush_size * 0.1
					point.y += (Math.random() - 0.5) * brush_size * 0.1
				when "smooth"
					for segment_name, segment of editing_entity.structure.segments
						if segment.a is point or segment.b is point
							other_point = if segment.a is point then segment.b else segment.a
							dx = other_point.x - point.x
							dy = other_point.y - point.y
							dist = Math.hypot(dx, dy)
							if dist > 0
								point.x += dx/dist * brush_size * 0.1
								point.y += dy/dist * brush_size * 0.1
				when "paint"
					indices_within_radius.push(Object.keys(editing_entity.structure.points).indexOf(point_name))
	
	if tool is "paint"
		if editing_entity.structure not instanceof PolygonStructure
			throw new Error "Paint tool only works on polygon structures"

		# Using serialization to edit the points as a simple list and automatically recompute the segments
		points_list = editing_entity.structure.toJSON().points

		# Find strands of points that are within the brush radius
		strands = []
		for index in indices_within_radius
			# Find an existing strand that this point should be part of
			strand = strands.find((strand) -> strand.some((point_index) -> point_index in [index - 1, index + 1]))
			if strand
				# If the point is already in a strand, add the point to the strand
				strand.push(index)
			else
				# If the point is not in a strand, create a new strand with the point
				strands.push([index])
		
		# Replace the strands with arcs around the center of the brush
		new_points_list = points_list.slice()
		# Sort the strands by decreasing index so that splicing doesn't mess up the indices of later splice operations
		strands.sort((a, b) -> b[0] - a[0])
		for strand in strands
			start = strand[0]
			end = strand[strand.length-1]
			a = points_list[start]
			b = points_list[end]
			# Find the shortest and longest angular differences between the strand's endpoints, from the brush center.
			angle_a = Math.atan2(a.y - local_mouse_position.y, a.x - local_mouse_position.x)
			angle_b = Math.atan2(b.y - local_mouse_position.y, b.x - local_mouse_position.x)
			angle_diff_a = angle_b - angle_a
			angle_diff_b = angle_a - angle_b
			if Math.abs(angle_diff_a) < Math.abs(angle_diff_b)
				angle_diff_short = angle_diff_a
				angle_diff_long = angle_diff_b
			else
				angle_diff_short = angle_diff_b
				angle_diff_long = angle_diff_a
			if angle_diff_short > Math.PI
				angle_diff_short -= Math.PI*2
			else if angle_diff_short < -Math.PI
				angle_diff_short += Math.PI*2
			if angle_diff_long > Math.PI
				angle_diff_long -= Math.PI*2
			else if angle_diff_long < -Math.PI
				angle_diff_long += Math.PI*2
			
			# Check if we should use the longer or shorter arc
			# For additive brushing, we want to do whichever will lead to more area of the resultant polygon.
			# Another way to look at it, the new points should not be inside the old polygon.
			get_new_points = (angle_diff) ->
				# Add new points and segments around the arc of the brush.
				points_per_radian = 2
				n_points = Math.ceil(Math.abs(angle_diff) * points_per_radian)
				n_points = Math.max(2, n_points)
				new_points = []
				for i in [0...n_points]
					angle = angle_a + angle_diff * i / (n_points-1)
					point = {
						x: local_mouse_position.x + Math.cos(angle) * brush_size
						y: local_mouse_position.y + Math.sin(angle) * brush_size
					}
					new_points.push(point)
				return new_points
			new_points_short_arc = get_new_points(angle_diff_short)
			new_points_long_arc = get_new_points(angle_diff_long)
			n_inside_short = new_points_short_arc.filter((point) -> editing_entity.structure.pointInPolygon(point)).length
			n_inside_long = new_points_long_arc.filter((point) -> editing_entity.structure.pointInPolygon(point)).length
			# console.log("n_inside_short:", n_inside_short, "n_inside_long:", n_inside_long, n_inside_short > n_inside_long)
			if n_inside_short > n_inside_long
				new_points = new_points_long_arc
			else
				new_points = new_points_short_arc
			
			# Splice the new points into the list of points
			new_points_list.splice(start, strand.length, ...new_points)

		# Note: this causes a duplicate signalChange() call; we could avoid it by not calling signalChange() below for this tool
		editing_entity.structure.fromJSON({points: new_points_list})

	editing_entity.structure.signalChange?()
