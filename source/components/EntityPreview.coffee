
class @EntityPreview extends React.Component
	constructor: (props)->
		super
		{entity, max_width, max_height} = props
		@entity = Entity.fromJSON(JSON.parse(JSON.stringify(entity)))
		@entity.facing_x = 1
		@view = new View
		entity_bbox = @entity.bbox()
		center_x = entity_bbox.x + entity_bbox.width / 2 - @entity.x
		center_y = entity_bbox.y + entity_bbox.height / 2 - @entity.y
		height = min(entity_bbox.height, max_height)
		scale = height / entity_bbox.height
		@view = new View
		@view.width = max_width
		@view.height = height
		@view.scale = scale
		@view.center_x = center_x
		@view.center_y = center_y
		@view.is_preview = true
	
	render: ->
		E "canvas", ref: (@canvas)=>
	
	update: ->
		entity_bbox = @entity.bbox()
		center_x = entity_bbox.x + entity_bbox.width / 2 - @entity.x
		center_y = entity_bbox.y + entity_bbox.height / 2 - @entity.y
		@view.center_x = center_x
		@view.center_y = center_y
		
		ctx = @canvas.getContext("2d")
		@canvas.width = @view.width
		@canvas.height = @view.height
		ctx.save()
		ctx.translate(@view.width/2, @view.height/2)
		ctx.scale(@view.scale, @view.scale)
		ctx.translate(-@view.center_x, -@view.center_y)
		@entity.draw(ctx, @view)
		ctx.restore()
