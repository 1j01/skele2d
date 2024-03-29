
import Entity from "./Entity.coffee"
import PolygonStructure from "../structure/PolygonStructure.coffee"
TAU = Math.PI * 2

export default class Terrain extends Entity
	constructor: ->
		super()
		@structure = new PolygonStructure
		@simplex = new window.SimplexNoise?()
		@seed = Math.random()
	
	initLayout: ->
		radius = 30
		n_points = 15
		for theta in [TAU/n_points..TAU] by TAU/n_points
			point_x = Math.sin(theta) * radius
			point_y = Math.cos(theta) * radius
			non_squished_point_y_component = Math.max(point_y, -radius*0.5)
			point_y = non_squished_point_y_component + (point_y - non_squished_point_y_component) * 0.4
			# point_y = non_squished_point_y_component + pow(0.9, point_y - non_squished_point_y_component)
			# point_y = non_squished_point_y_component + pow(point_y - non_squished_point_y_component, 0.9)
			@structure.addVertex(point_x, point_y)
	
	toJSON: ->
		def = {}
		def[k] = v for k, v of @ when k isnt "simplex"
		def
	
	generate: ->
		@width = 5000
		@left = -2500
		@right = @left + @width
		@max_height = 400
		@bottom = 300
		res = 20
		@structure.clear()
		@structure.addVertex(@right, @bottom)
		@structure.addVertex(@left, @bottom)
		for x in [@left..@right] by res
			if @simplex
				noise =
					@simplex.noise2D(x / 2400, 0) +
					@simplex.noise2D(x / 500, 10) / 5 +
					@simplex.noise2D(x / 50, 30) / 100
			else
				# noise = Math.random() * 2 - 1
				# noise = Math.sin(x / 100) * 0.5 + 0.5
				noise = 0
			@structure.addVertex(x, @bottom - (noise + 1) / 2 * @max_height)
	
	draw: (ctx, view)->
		ctx.beginPath()
		for point_name, point of @structure.points
			ctx.lineTo(point.x, point.y)
		ctx.closePath()
		ctx.fillStyle = "#a5f"
		ctx.fill()
