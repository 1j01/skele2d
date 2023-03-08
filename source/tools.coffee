export run_tool = (tool, editing_entity, mouse_in_world, mouse_world_delta_x, mouse_world_delta_y, brush_size)->
	local_mouse_position = editing_entity.fromWorld(mouse_in_world)

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
	
	editing_entity.structure.signalChange?()
