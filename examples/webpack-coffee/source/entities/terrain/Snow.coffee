import {Terrain, addEntityClass} from "skele2d"

export default class Snow extends Terrain
	addEntityClass(@)
	constructor: ->
		super()
		@bbox_padding = 20
	
	draw: (ctx, view)->
		ctx.beginPath()
		for point_name, point of @structure.points
			ctx.lineTo(point.x, point.y)
		ctx.closePath()
		ctx.fillStyle = "#fcfeff"
		ctx.fill()
