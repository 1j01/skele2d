import PolygonStructure from "./structure/PolygonStructure.coffee"
import {distanceToLineSegment, closestPointOnLineSegment} from "./helpers.coffee"

towards = (starting_point, ending_point, max_distance)->
	dx = ending_point.x - starting_point.x
	dy = ending_point.y - starting_point.y
	dist = Math.hypot(dx, dy)
	if dist > max_distance
		{
			x: starting_point.x + dx/dist * max_distance
			y: starting_point.y + dy/dist * max_distance
		}
	else
		ending_point

line_circle_intersection = (x1, y1, x2, y2, cx, cy, r)->
	# https://stackoverflow.com/a/1073336/2624876
	# dx = x2 - x1
	# dy = y2 - y1
	# dr = Math.hypot(dx, dy)
	# D = x1 * y2 - x2 * y1
	# discriminant = r**2 * dr**2 - D**2
	# if discriminant < 0
	# 	[]
	# else
	# 	sqrt_discriminant = Math.sqrt(discriminant)
	# 	x1 = (D * dy + Math.sign(dy) * dx * sqrt_discriminant) / dr**2
	# 	x2 = (D * dy - Math.sign(dy) * dx * sqrt_discriminant) / dr**2
	# 	y1 = (-D * dx + Math.abs(dy) * sqrt_discriminant) / dr**2
	# 	y2 = (-D * dx - Math.abs(dy) * sqrt_discriminant) / dr**2
	# 	[{x: x1, y: y1}, {x: x2, y: y2}]

	if x1 == x2
		# Handle vertical line segment case
		x_intersect1 = x1
		x_intersect2 = x1
		y_intersect1 = cy + Math.sqrt(r**2 - (x_intersect1 - cx)**2)
		y_intersect2 = cy - Math.sqrt(r**2 - (x_intersect2 - cx)**2)

		# Check if the intersection points are on the line segment
		on_segment1 = (y1 <= y_intersect1 <= y2 or y2 <= y_intersect1 <= y1)
		on_segment2 = (y1 <= y_intersect2 <= y2 or y2 <= y_intersect2 <= y1)
	else

		# Calculate the discriminant of the quadratic equation for intersection
		dx = x2 - x1
		dy = y2 - y1
		a = dx**2 + dy**2
		b = 2 * dx * (x1 - cx) + 2 * dy * (y1 - cy)
		c = cx**2 + cy**2 + x1**2 + y1**2 - 2 * (cx * x1 + cy * y1) - r**2
		discriminant = Math.sqrt(b**2 - 4 * a * c)

		# Calculate the x-coordinates of the two intersection points
		x_intersect1 = (-b + discriminant) / (2 * a)
		x_intersect2 = (-b - discriminant) / (2 * a)

		# Calculate the y-coordinates of the two intersection points
		y_intersect1 = y1 + (y2 - y1) * (x_intersect1 - x1) / (x2 - x1)
		y_intersect2 = y1 + (y2 - y1) * (x_intersect2 - x1) / (x2 - x1)

		# Check if the intersection points are on the line segment
		on_segment1 = (x1 <= x_intersect1 <= x2 or x2 <= x_intersect1 <= x1) and (y1 <= y_intersect1 <= y2 or y2 <= y_intersect1 <= y1)
		on_segment2 = (x1 <= x_intersect2 <= x2 or x2 <= x_intersect2 <= x1) and (y1 <= y_intersect2 <= y2 or y2 <= y_intersect2 <= y1)

	# Return the intersection points
	intersection_points = []
	intersection_points.push({x: x_intersect1, y: y_intersect1}) if on_segment1
	intersection_points.push({x: x_intersect2, y: y_intersect2}) if on_segment2
	return intersection_points



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

		# Find also the segments that are within the brush radius
		for segment_name, segment of editing_entity.structure.segments
			if distanceToLineSegment(local_mouse_position, segment.a, segment.b) < brush_size
				index_a = Object.values(editing_entity.structure.points).indexOf(segment.a)
				index_b = Object.values(editing_entity.structure.points).indexOf(segment.b)
				if index_a not in indices_within_radius
					indices_within_radius.push(index_a)
				if index_b not in indices_within_radius
					indices_within_radius.push(index_b)

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
		
		# Sort the strand's points by increasing index so that they're monotonic in
		# the case that indices are added via the segments
		for strand in strands
			strand.sort((a, b) -> a - b)

		# Sort the strands by decreasing index so that splicing doesn't mess up the indices of later splice operations
		strands.sort((a, b) -> b[0] - a[0])

		# Replace the strands with arcs around the center of the brush

		new_points_list = points_list.slice()
		for strand in strands
			start = strand[0]
			end = strand[strand.length-1]
			start_point = points_list[start]
			second_point = points_list[start+1]
			end_point = points_list[end]
			second_to_last_point = points_list[end-1]
			# Note: end point and second point, as well as start point and second-to-last point,
			# may be the same points, if only one segment (and no points) are within the brush radius
			# If we take the first intersect of the first segment and the last intersect of the last segment,
			# it should still get two distinct points on the circle in that case.
			intersects_a = line_circle_intersection(start_point.x, start_point.y, second_point.x, second_point.y, local_mouse_position.x, local_mouse_position.y, brush_size)
			intersects_b = line_circle_intersection(second_to_last_point.x, second_to_last_point.y, end_point.x, end_point.y, local_mouse_position.x, local_mouse_position.y, brush_size)
			a = intersects_a[0] ? start_point
			b = intersects_b[1] ? intersects_b[0] ? end_point

			# c = closestPointOnLineSegment(local_mouse_position, start_point, end_point)
			# a = towards(c, start_point, brush_size)
			# b = towards(c, end_point, brush_size)
			# a = closestPointOnLineSegment(a, start_point, end_point)
			# b = closestPointOnLineSegment(b, start_point, end_point)
			# Find the clockwise and counter-clockwise arcs between the strand's endpoints, from the brush center.
			angle_a = Math.atan2(a.y - local_mouse_position.y, a.x - local_mouse_position.x)
			angle_b = Math.atan2(b.y - local_mouse_position.y, b.x - local_mouse_position.x)
			angle_diff_cw = (angle_b - angle_a) % (2 * Math.PI)
			angle_diff_cw += 2 * Math.PI if angle_diff_cw < 0
			angle_diff_ccw = (angle_a - angle_b) % (2 * Math.PI)
			angle_diff_ccw += 2 * Math.PI if angle_diff_ccw < 0

			# Check which arc we should use
			# For additive brushing, we want to do whichever will lead to more area of the resultant polygon.
			# Another way to look at it, the new points should not be inside the old polygon.
			get_new_points = (angle_diff) ->
				# Add new points and segments around the arc of the brush.
				points_per_radian = 2
				n_points = Math.ceil(Math.abs(angle_diff) * points_per_radian)
				n_points = Math.max(2, n_points)
				new_points = []
				for i in [0...n_points]
					angle = angle_a - angle_diff * i / (n_points-1)
					point = {
						x: local_mouse_position.x + Math.cos(angle) * brush_size
						y: local_mouse_position.y + Math.sin(angle) * brush_size
					}
					new_points.push(point)
				return new_points
			new_points_cw_arc = get_new_points(angle_diff_cw)
			new_points_ccw_arc = get_new_points(angle_diff_ccw)
			n_inside_cw = new_points_cw_arc.filter((point) -> editing_entity.structure.pointInPolygon(point)).length
			n_inside_ccw = new_points_ccw_arc.filter((point) -> editing_entity.structure.pointInPolygon(point)).length
			# console.log("n_inside_cw:", n_inside_cw, "n_inside_ccw:", n_inside_ccw, n_inside_cw > n_inside_ccw)
			if n_inside_cw > n_inside_ccw
				new_points = new_points_ccw_arc
			else
				new_points = new_points_cw_arc
			
			# Splice the new points into the list of points
			new_points_list.splice(start+1, strand.length-2, ...new_points)

		# Note: this causes a duplicate signalChange() call; we could avoid it by not calling signalChange() below for this tool
		editing_entity.structure.fromJSON({points: new_points_list})

	editing_entity.structure.signalChange?()
