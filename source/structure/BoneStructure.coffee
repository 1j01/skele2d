
class @BoneStructure extends Structure
	
	addPoint: (name)->
		if @points[name]
			throw new Error "point/segment '#{name}' already exists adding point '#{name}'"
		@points[name] = {x: 0, y: 0, name}
	
	addSegment: (def)->
		{from, to, name} = def
		to ?= name
		if @segments[name]
			throw new Error "segment '#{name}' already exists adding segment '#{name}'"
		if @points[to]
			throw new Error "point/segment '#{name}' already exists adding segment '#{name}'"
		unless @points[from]
			throw new Error "point/segment '#{from}' does not exist yet adding segment '#{name}'"
		@points[to] = {x: 0, y: 0, name: to}
		@segments[name] = {a: @points[from], b: @points[to], from, to, name}
		@segments[name][k] = v for k, v of def when v?
		return name
	
	stepLayout: ({center, repel, gravity, collision, velocity}={})->
		forces = {}
		
		center_around = {x: 0, y: 0}
		
		for point_name, point of @points
			forces[point_name] = {x: 0, y: 0}
			
			if center
				dx = center_around.x - point.x
				dy = center_around.y - point.y
				dist = sqrt(dx * dx + dy * dy)
				forces[point_name].x += dx * dist / 100000
				forces[point_name].y += dy * dist / 100000
			
			if repel
				for other_point_name, other_point of @points
					dx = other_point.x - point.x
					dy = other_point.y - point.y
					dist = sqrt(dx * dx + dy * dy)
					delta_dist = 5 - dist
					unless delta_dist is 0
						forces[point_name].x += dx / delta_dist / 1000
						forces[point_name].y += dy / delta_dist / 1000
			
			if gravity
				forces[point_name].y += gravity
		
		for segment_name, segment of @segments
			dx = segment.a.x - segment.b.x
			dy = segment.a.y - segment.b.y
			dist = sqrt(dx * dx + dy * dy)
			delta_dist = dist - (segment.length ? 50)
			delta_dist = min(delta_dist, 100)
			forces[segment.a.name].x -= dx * delta_dist / 1000
			forces[segment.a.name].y -= dy * delta_dist / 1000
			forces[segment.b.name].x += dx * delta_dist / 1000
			forces[segment.b.name].y += dy * delta_dist / 1000

		for point_name, force of forces
			point = @points[point_name]
			if collision
				point.vx ?= 0
				point.vy ?= 0
				point.vx += force.x
				point.vy += force.y
				move_x = point.vx
				move_y = point.vy
				resolution = 0.5
				while abs(move_x) > resolution
					go = sign(move_x) * resolution
					if collision({x: point.x + go, y: point.y})
						point.vx *= 0.99
						if collision({x: point.x + go, y: point.y - 1})
							break
						else
							point.y -= 1
					move_x -= go
					point.x += go
				while abs(move_y) > resolution
					go = sign(move_y) * resolution
					if collision({x: point.x, y: point.y + go})
						point.vy *= 0.9 # as opposed to `point.vy = 0` so it sticks to the ground when going downhill
						break
					move_y -= go
					point.y += go
			else
				point.x += force.x
				point.y += force.y
