import {Component} from "react"
import E from "react-script"
import {distance} from "../helpers.coffee"
import {entityClasses} from "../entity-class-registry.coffee"
import EntityPreview from "./EntityPreview.coffee"

export default class EntitiesBar extends Component
	constructor: ->
		super()
		@state = {visible: no}
		@cells = []
		@entity_previews = []
		for entity_class_name, EntityClass of entityClasses
			cell_name = entity_class_name.replace(/[a-z][A-Z]/g, (m)-> "#{m[0]} #{m[1]}")
			preview_error = null
			preview_entity = null
			try
				preview_entity = new EntityClass
				preview_entity.initLayout()
			catch error
				preview_error = error
			cell = {
				EntityClass
				name: cell_name
				preview_entity
				preview_error
			}
			@cells.push(cell)
	
	render: ->
		{editor} = @props
		{visible} = @state
		cell_preview_width = 200
		max_cell_preview_height = 100
		@entity_previews = []
		E ".bar.sidebar.entities-bar", class: {visible},
			for cell, i in @cells
				E "article.cell.grabbable",
					key: i
					onMouseDown: do (cell)=> (e)=>
						editor.selected_entities = []
						mouse_start = {x: e.clientX, y: e.clientY}
						addEventListener "mousemove", onmousemove = (e)=>
							if distance(mouse_start, {x: e.clientX, y: e.clientY}) > 4
								editor.undoable =>
									entity = new cell.EntityClass
									entity.initLayout()
									editor.world.entities.push(entity)
									editor.dragEntities([entity])
									removeEventListener "mousemove", onmousemove
									removeEventListener "mouseup", onmouseup
						addEventListener "mouseup", onmouseup = (e)=>
							removeEventListener "mousemove", onmousemove
							removeEventListener "mouseup", onmouseup
					E "h1.name", cell.name
					E EntityPreview,
						entity: cell.preview_entity
						max_width: cell_preview_width
						max_height: max_cell_preview_height
						preview_error: cell.preview_error
						ref: (ep)=>
							@entity_previews.push(ep) if ep?
	
	update: (show)=>
		{editor} = @props
		
		show = show and editor.dragging_entities.length is 0 and not editor.editing_entity
		if show isnt @state.visible
			@setState visible: show
		
		if show
			for entity_preview in @entity_previews
				entity_preview.update()
