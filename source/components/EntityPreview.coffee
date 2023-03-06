import {Component} from "react"
import E from "react-script"
import Entity from "../base-entities/Entity.coffee"
import View from "../View.coffee"

export default class EntityPreview extends Component
	constructor: (props)->
		super()
		{entity, max_width, max_height} = props
		@state = {}
		try
			@entity = Entity.fromJSON(JSON.parse(JSON.stringify(entity)))
			@entity.facing_x = 1
			@view = new View
			entity_bbox = @entity.bbox()
			center_x = entity_bbox.x + entity_bbox.width / 2 - @entity.x
			center_y = entity_bbox.y + entity_bbox.height / 2 - @entity.y
			height = Math.min(entity_bbox.height, max_height)
			scale = height / entity_bbox.height
		catch error
			@state.preview_error = error
			console.log props
		@view = new View
		@view.width = max_width
		@view.height = if isFinite(height) then height else max_height
		@view.scale = if isFinite(scale) then scale else 1
		@view.center_x = center_x
		@view.center_y = center_y
		@view.is_preview = true
	
	render: ->
		# Props has priority over state for preview_error because errors during
		# construction of an entity are more important than errors during rendering.
		# An error during construction can easily lead to bogus errors during rendering.
		preview_error = @props.preview_error or @state.preview_error
		# Chrome includes the error message in the stack trace, but Firefox doesn't.
		if preview_error
			if preview_error.stack.includes(preview_error.toString())
				error_details = preview_error.stack
			else
				error_details = "#{preview_error.toString()}\n#{preview_error.stack}"

		E "div.entity-preview",
			E "canvas", ref: (@canvas)=>
			if preview_error?
				E "div.error", title: error_details, preview_error.toString()
	
	update: ->
		@canvas.width = @view.width
		@canvas.height = @view.height
		try
			entity_bbox = @entity.bbox()
			center_x = entity_bbox.x + entity_bbox.width / 2 - @entity.x
			center_y = entity_bbox.y + entity_bbox.height / 2 - @entity.y
			@view.center_x = center_x
			@view.center_y = center_y
			
			ctx = @canvas.getContext("2d")
			ctx.save()
			ctx.translate(@view.width/2, @view.height/2)
			ctx.scale(@view.scale, @view.scale)
			ctx.translate(-@view.center_x, -@view.center_y)
			@entity.draw(ctx, @view)
			ctx.restore()
		catch error
			# Earlier errors are generally more pertinent than later errors.
			@setState({preview_error: error}) unless @state.preview_error?
