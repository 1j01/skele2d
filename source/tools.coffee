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

line_circle_intersection = (x1, y1, x2, y2, cx, cy, r) ->
	intersections = []

	# Translate line to new coordinate system with origin at center of circle.
	x1 -= cx
	y1 -= cy
	x2 -= cx
	y2 -= cy

	dx = x2 - x1
	dy = y2 - y1
	if dy == 0 and dx == 0
		# Handle degenerate case where line is a point.
		if Math.hypot(x1, y1) == r
			intersections.push {x: x1, y: y1}
	else
		horizontal = dy == 0
		if horizontal
			# Handle horizontal line segment case by swapping x and y coordinates.
			[x1, y1, x2, y2, dx, dy] = [y1, x1, y2, x2, dy, dx]
		dr = Math.hypot(dx, dy)
		D = x1 * y2 - (x2 * y1)
		discriminant = r ** 2 * dr ** 2 - D ** 2
		if discriminant < 0
			# No intersection
		else
			# Assuming two intersection points
			sqrt_discriminant = Math.sqrt(discriminant)
			i1_x = (D * dy + Math.sign(dy) * dx * sqrt_discriminant) / dr ** 2
			i2_x = (D * dy - (Math.sign(dy) * dx * sqrt_discriminant)) / dr ** 2
			i1_y = (-D * dx + Math.abs(dy) * sqrt_discriminant) / dr ** 2
			i2_y = (-D * dx - (Math.abs(dy) * sqrt_discriminant)) / dr ** 2
			# Can't check dy === 0 because it was swapped with dx above.
			# Can't check dx === 0 because that would falsely trigger for vertical lines.
			if horizontal
				# For horizontal line segment case, swap x and y coordinates back.
				[i1_x, i1_y, i2_x, i2_y, x1, y1, x2, y2, dx, dy] = [i1_y, i1_x, i2_y, i2_x, y1, x1, y2, x2, dy, dx]
			intersections.push { x: i1_x, y: i1_y }, { x: i2_x, y: i2_y }

	# Translate intersection points back to original coordinate system
	for point in intersections
		point.x += cx
		point.y += cy

	# Associate intersection points with the closest line endpoints
	along_line = (x, y) => ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy)
	if intersections.length == 2
		t1 = along_line(intersections[0].x, intersections[0].y)
		t2 = along_line(intersections[1].x, intersections[1].y)
		intersections.reverse() if t1 > t2

	return intersections

export run_tool = (tool, editing_entity, mouse_in_world, mouse_world_delta_x, mouse_world_delta_y, brush_size, brush_additive)->
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
					# Move points very near the brush circumference towards the center of the brush
					# to avoid artifacts in the polygon brushing algorithm.
					region = brush_size * 0.001
					if dist > brush_size * (1 - region)
						point.x -= dx/dist * brush_size * region
						point.y -= dy/dist * brush_size * region
	
	if tool is "paint"
		if editing_entity.structure not instanceof PolygonStructure
			throw new Error "Paint tool only works on polygon structures"

		# Using serialization to edit the points as a simple list and automatically recompute the segments
		points_list = editing_entity.structure.toJSON().points
		# for referential equality
		original_points_list = Object.values(editing_entity.structure.points)

		# Find strands of points that are within the brush radius,
		# or connected to points that are within the brush radius.
		# First initialize strands from segments that cross or are within the brush radius.
		strands = []
		for segment_name, segment of editing_entity.structure.segments
			if (
				(segment.a in indices_within_radius and segment.b in indices_within_radius) or
				distanceToLineSegment(local_mouse_position, segment.a, segment.b) < brush_size
			)
				strands.push([original_points_list.indexOf(segment.a), original_points_list.indexOf(segment.b)])

		# console.log("strands before joining", strands.join(" --- "))

		# Then join strands that share points within the brush radius,
		# until no more strands can be joined.
		loop
			joined = no
			for strand in strands
				for other_strand in strands
					if strand is other_strand
						continue
					for point_index in strand when point_index in indices_within_radius
						index_of_shared_point_index_in_other_strand = other_strand.indexOf(point_index)
						if index_of_shared_point_index_in_other_strand isnt -1
							strands.splice(strands.indexOf(strand), 1)
							strands.splice(strands.indexOf(other_strand), 1)
							# Exclude the duplicate point index from the joined strand
							index_of_shared_point_index_in_strand = strand.indexOf(point_index)
							strand.splice(index_of_shared_point_index_in_strand, 1)
							if index_of_shared_point_index_in_other_strand is 0
								joined_strand = [...strand, ...other_strand]
							else
								joined_strand = [...other_strand, ...strand]
							strands.push(joined_strand)
							joined = yes
							break
						break if joined
					break if joined
				break if joined
			break unless joined

		# console.log("strands after joining", strands.join(" --- "))

		# Sort the strands by decreasing index so that splicing doesn't mess up the indices of later splice operations
		strands.sort((a, b) -> b[0] - a[0])

		# Handle the case where the whole polygon is within the brush radius
		# by making the strand cyclic, repeating the first index at the end.
		# If entities ever support multiple polygons, this will need to be
		# generalized using the segments information.
		if points_list.every (point, index) -> index in indices_within_radius
			strands[0].push(strands[0][0])

		# Replace the strands with arcs around the center of the brush

		new_points_list = points_list.slice()
		splice_offset = 0
		for strand in strands
			if strand.length < 2
				console.log("strand too short", strand.join(","))
				continue

			start = strand[0]
			end = strand[strand.length-1]
			if strand.length is 2
				# Edge case dealing with a single edge.
				# We could optimize this to only compute intersections once,
				# but for now I'm duplicating the computation so I don't have to duplicate the code.
				second = end
				second_to_last = start
			else
				second = (start+1) %% points_list.length
				second_to_last = (end-1) %% points_list.length

			start_point = points_list[start]
			second_point = points_list[second]
			end_point = points_list[end]
			second_to_last_point = points_list[second_to_last]

			if start is end
				# Handle case where the whole polygon is encompassed by the brush
				angle_a = 0
				angle_b = 2 * Math.PI
				short_arc = long_arc = 2 * Math.PI
				start_point = a = {x: local_mouse_position.x + Math.cos(angle_a) * brush_size, y: local_mouse_position.y + Math.sin(angle_a) * brush_size}
				end_point = b = {x: local_mouse_position.x + Math.cos(angle_b) * brush_size, y: local_mouse_position.y + Math.sin(angle_b) * brush_size}
			else
				# Note: end point and second point, as well as start point and second-to-last point,
				# may be the same points, if only one segment (and no points) are within the brush radius
				# If we take the first intersect of the first segment and the last intersect of the last segment,
				# it should still get two distinct points on the circle in that case.
				intersects_a = line_circle_intersection(start_point.x, start_point.y, second_point.x, second_point.y, local_mouse_position.x, local_mouse_position.y, brush_size)
				intersects_b = line_circle_intersection(second_to_last_point.x, second_to_last_point.y, end_point.x, end_point.y, local_mouse_position.x, local_mouse_position.y, brush_size)
				a = intersects_a[0] #? start_point
				b = intersects_b[1] #? intersects_b[0] ? end_point

				if not a
					console.log "Intersection not found between segment #{start} to #{second} and the brush circle"
					continue
				if not b
					console.log "Intersection not found between segment #{second_to_last} to #{end} and the brush circle"
					continue
				# console.log "Segment #{start} to #{second} intersects the brush circle"
				# console.log "Segment #{second_to_last} to #{end} intersects the brush circle"

				# c = closestPointOnLineSegment(local_mouse_position, start_point, end_point)
				# a = towards(c, start_point, brush_size)
				# b = towards(c, end_point, brush_size)
				# a = closestPointOnLineSegment(a, start_point, end_point)
				# b = closestPointOnLineSegment(b, start_point, end_point)
				# Find the short and long arcs between the strand's endpoints, from the brush center.
				angle_a = Math.atan2(a.y - local_mouse_position.y, a.x - local_mouse_position.x)
				angle_b = Math.atan2(b.y - local_mouse_position.y, b.x - local_mouse_position.x)
				arc_a = (angle_a - angle_b + Math.PI * 2) % (Math.PI * 2)
				arc_b = -(Math.PI * 2 - arc_a)
				short_arc = if Math.abs(arc_a) < Math.abs(arc_b) then arc_a else arc_b
				long_arc = if Math.abs(arc_a) < Math.abs(arc_b) then arc_b else arc_a

			# Check which arc we should use
			# For additive brushing, we want to do whichever will lead to more area of the resultant polygon.
			# Another way to look at it, the new points should not be inside the old polygon.
			# Subtractive brushing is the opposite.
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
			new_points_short_arc = get_new_points(short_arc)
			new_points_long_arc = get_new_points(long_arc)

			# Hit-test solution is not totally correct
			# n_inside_short = new_points_short_arc.filter((point) -> editing_entity.structure.pointInPolygon(point)).length
			# n_inside_long = new_points_long_arc.filter((point) -> editing_entity.structure.pointInPolygon(point)).length
			
			# if (n_inside_short > n_inside_long) == brush_additive
			# 	new_points = new_points_long_arc
			# else
			# 	new_points = new_points_short_arc

			# Analytic solution using shoelace formula
			signed_area = (segments) ->
				sum = 0
				for segment in segments
					sum += (segment.b.x - segment.a.x) * (segment.b.y + segment.a.y)
				return sum / 2
			
			shared_signed_area = signed_area(Object.values(editing_entity.structure.segments).filter((segment) -> segment.a not in strand and segment.b not in strand))
			
			total_expected_area = (new_arc_points)->
				arc_segments = [start_point, ...new_arc_points].map((point, i) -> {a: point, b: new_arc_points[i+1] ? end_point})
				arc_signed_area = signed_area(arc_segments)
				return Math.abs(arc_signed_area + shared_signed_area)
			
			if (total_expected_area(new_points_short_arc) < total_expected_area(new_points_long_arc)) == brush_additive
				new_points = new_points_long_arc
			else
				new_points = new_points_short_arc
			
			# Splice the new points into the list of points
			cyclic_splice = (list, start, delete_count, ...items) ->
				# This function preserves earlier indices even when wrapping
				# and inserting/deleting different numbers of items, WHEN POSSIBLE,
				# by splitting up the inserted items according to the number of items deleted.
				# Specifically, the number of items inserted that are wrapped around to the end of the list
				# is matched to the number of items deleted that are wrapped around to the beginning of the list.
				# However, if the number of items deleted (that are wrapped) is greater than the number of items inserted,
				# it is impossible to preserve earlier indices, and splice_offset will be updated instead.
				start += splice_offset
				delete_without_wrapping = Math.min(delete_count, list.length - start)
				delete_with_wrapping = delete_count - delete_without_wrapping
				insert_wrapped = Math.min(delete_with_wrapping, items.length)
				insert_without_wrapping = items.length - insert_wrapped
				list.splice(start, delete_without_wrapping, ...items.slice(0, insert_without_wrapping))
				if delete_with_wrapping > 0
					list.splice(0, delete_with_wrapping, ...items.slice(insert_without_wrapping))
					splice_offset += insert_wrapped - delete_with_wrapping
				return
			if start is end
				# If whole polygon is encompassed, replace whole strand
				# Note: since this strand duplicates first as last, subtract one from the length
				cyclic_splice(new_points_list, start, strand.length-1, ...new_points)
				# new_points_list = new_points
			else
				# Otherwise, make sure to keep the start and end points
				# which may lie outside the brush radius
				cyclic_splice(new_points_list, start+1, strand.length-2, ...new_points)

		# Finally, merge points that are too close together
		# (In continuous brushing, many points may be added in the same place if you're not moving the mouse.)
		# Only affect points near the brush. Otherwise it would cause big git diffs in the world data,
		# and probably general confusion, because you'd be changing points that you didn't even see,
		# in subtle, or if buggy, unpredictable ways.
		min_distance = 0.01
		cluster_start_index = 0
		cluster_start_pos = null # for distance threshold for the current cluster
		cluster_sum_pos = null # for finding the average position
		radius = brush_size * 1.01
		# TODO: handle wrapping around the end of the list
		# Should just need to extend iteration by one, and modulo the index,
		# since the points at the start will already be de-clustered.
		# It wouldn't be a perfectly symmetric solution, but it should be good enough.
		i = 0
		while i < new_points_list.length
			point = new_points_list[i]
			cluster_start_pos ?= point
			cluster_sum_pos ?= {x: 0, y: 0}
			dist_from_cluster_start = Math.hypot(point.x - cluster_start_pos.x, point.y - cluster_start_pos.y)
			if dist_from_cluster_start > min_distance or Math.hypot(point.x - local_mouse_position.x, point.y - local_mouse_position.y) > radius
				# If this point is far enough from the start of the cluster, then we're done with the cluster
				# and can average the positions
				if i - cluster_start_index > 1
					# If there were at least two points in the cluster, then average them
					average_pos = {
						x: cluster_sum_pos.x / (i - cluster_start_index)
						y: cluster_sum_pos.y / (i - cluster_start_index)
					}
					new_points_list.splice(cluster_start_index, i - cluster_start_index, average_pos)
					i = cluster_start_index + 1
				# Start a new cluster
				cluster_start_index = i
				cluster_start_pos = point
				cluster_sum_pos = {x: point.x, y: point.y}
			else
				# If this point is close enough to the start of the cluster, then add it to the cluster
				cluster_sum_pos.x += point.x
				cluster_sum_pos.y += point.y
			i++
		# If there's a cluster at the end, average it
		if i - cluster_start_index > 1
			average_pos = {
				x: cluster_sum_pos.x / (i - cluster_start_index)
				y: cluster_sum_pos.y / (i - cluster_start_index)
			}
			new_points_list.splice(cluster_start_index, i - cluster_start_index, average_pos)

		# Note: this causes a duplicate signalChange() call; we could avoid it by not calling signalChange() below for this tool
		editing_entity.structure.fromJSON({points: new_points_list})

	editing_entity.structure.signalChange?()
