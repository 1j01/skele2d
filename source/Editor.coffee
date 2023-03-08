
import ReactDOM from "react-dom"
import E from "react-script"
import EntitiesBar from "./components/EntitiesBar.coffee"
import AnimBar from "./components/AnimBar.coffee"
import ToolsBar from "./components/ToolsBar.coffee"

import View from "./View.coffee"
import Terrain from "./base-entities/Terrain.coffee"
import Entity from "./base-entities/Entity.coffee"
import Pose from "./structure/Pose.coffee"
import BoneStructure from "./structure/BoneStructure.coffee"
import PolygonStructure from "./structure/PolygonStructure.coffee"
import {distanceToLineSegment, distance} from "./helpers.coffee"
import {entityClasses} from "./entity-class-registry.coffee"
import {run_tool} from "./tools.coffee"
TAU = Math.PI * 2

import "./styles.css"

import {Menu as JSMenu, MenuItem as JSMenuItem} from "./jsMenus/jsMenus.js"
import "./jsMenus/jsMenus.css"
if nw?
	{Menu, MenuItem} = nw
else
	Menu = JSMenu
	MenuItem = JSMenuItem

fs = window.require? "fs"
path = window.require? "path"

export default class Editor
	constructor: (@world, @view, @view_to, canvas, @mouse)->
		@previous_mouse_world_x = -Infinity
		@previous_mouse_world_y = -Infinity
		@editing = yes
		
		@selected_entities = []
		@hovered_entities = []
		@selected_points = []
		@hovered_points = []
		@hovered_segments = []
		
		@selection_box = null
		@editing_entity = null
		@editing_entity_anim_name = null
		# @editing_entity_pose_name = null
		# @editing_entity_animation_name = null
		@editing_entity_animation_frame_index = null
		
		@dragging_points = []
		@dragging_segments = []
		@dragging_entities = []
		
		@drag_offsets = []
		@view_drag_start_in_world = null
		@view_drag_momentum = {x: 0, y: 0}
		@last_click_time = null
		
		@tool = "select"
		@brush_size = 50
		# @sculpt_adding = no
		# @sculpt_removing = no
		@sculpt_additive = yes
		@tool_active = no
		
		@undos = []
		@redos = []
		@clipboard = {}
		@warning_message = null
		@show_warning = no
		@warning_tid = -1
		@react_root_el = document.createElement("div")
		@react_root_el.className = "react-root"
		document.body.appendChild(@react_root_el)
		
		@renderDOM()
		
		if fs?
			@save_path = "world.json"
			# @save_path = path.join(nw.App.dataPath, "world.json")
		
		@grab_start = null
		
		addEventListener "contextmenu", (e)=>
			e.preventDefault()
			return unless @editing

			menu = new Menu
			
			# if @selected_entities.length is 0
			if @hovered_entities.length and @hovered_entities[0] not in @selected_entities
				@selected_entities = (entity for entity in @hovered_entities)
			
			menu.append(new MenuItem(
				label: 'Undo'
				click: => @undo()
				enabled: @undos.length
			))
			menu.append(new MenuItem(
				label: 'Redo'
				click: => @redo()
				enabled: @redos.length
			))
			menu.append(new MenuItem(type: 'separator'))
			menu.append(new MenuItem(
				label: 'Cut'
				click: => @cut()
				enabled: @selected_entities.length
			))
			menu.append(new MenuItem(
				label: 'Copy'
				click: => @copy()
				enabled: @selected_points.length or @selected_entities.length
			))
			menu.append(new MenuItem(
				label: 'Paste'
				click: => @paste()
				enabled: if @editing_entity then @clipboard.point_positions? else @clipboard.entities?.length
			))
			menu.append(new MenuItem(
				label: 'Delete'
				click: => @delete()
				enabled: @selected_entities.length
			))
			menu.append(new MenuItem(
				label: 'Select All'
				click: => @selectAll()
				enabled: @world.entities.length
			))
			menu.append(new MenuItem(
				label: 'Select Same Type'
				click: => @selectAllSameType()
				enabled: @world.entities.length and @selected_entities.length
			))
			menu.append(new MenuItem(type: 'separator'))
			
			if @editing_entity
				
				modifyPose = (fn)=>
					EntityClass = entityClasses[@editing_entity._class_]
					frame_index = @editing_entity_animation_frame_index
					if frame_index?
						old_pose = EntityClass.animations[@editing_entity_anim_name][frame_index]
					else
						old_pose = @editing_entity.structure.getPose()
					new_pose = fn(old_pose)
					@editing_entity.structure.setPose(new_pose)
					if frame_index?
						EntityClass.animations[@editing_entity_anim_name][frame_index] = new_pose
					else
						EntityClass.poses[@editing_entity_anim_name] = new_pose
					Entity.saveAnimations(EntityClass)
				
				# TODO: allow flipping the current pose, just don't save it? or save the world where it's stored?
				# also, allow flipping terrain
				menu.append(new MenuItem(
					label: 'Flip Pose Horizontally'
					enabled: @editing_entity_anim_name and @editing_entity_anim_name isnt "Current Pose"
					click: => modifyPose(Pose.horizontallyFlip)
				))
				menu.append(new MenuItem(
					label: 'Flip Pose Vertically'
					enabled: @editing_entity_anim_name and @editing_entity_anim_name isnt "Current Pose"
					click: => modifyPose(Pose.verticallyFlip)
				))
				menu.append(new MenuItem(type: 'separator'))
				menu.append(new MenuItem(
					label: 'Finish Editing Entity'
					click: => @finishEditingEntity()
				))
			else
				menu.append(new MenuItem(
					label: 'Edit Entity'
					click: => @editEntity(@selected_entities[0])
					enabled: @selected_entities.length
				))
			
			menu.popup(e.x, e.y)
			return false
		
		handle_scroll = (e)=>
			return unless e.target is canvas
			
			zoom_factor = 1.2
			
			current_scale = @view.scale
			current_center_x = @view.center_x
			current_center_y = @view.center_y
			
			@view.scale = @view_to.scale
			@view.center_x = @view_to.center_x
			@view.center_y = @view_to.center_y
			
			pivot = @view.toWorld(x: e.clientX, y: e.clientY)
			@view_to.scale =
				if e.detail < 0 or e.wheelDelta > 0
					@view_to.scale * zoom_factor
				else
					@view_to.scale / zoom_factor
			
			@view.scale = @view_to.scale
			mouse_after_preliminary_scale = @view.toWorld(x: e.clientX, y: e.clientY)
			@view_to.center_x += (pivot.x - mouse_after_preliminary_scale.x)
			@view_to.center_y += (pivot.y - mouse_after_preliminary_scale.y)
			
			@view.scale = current_scale
			@view.center_x = current_center_x
			@view.center_y = current_center_y
		
		addEventListener "mousewheel", handle_scroll
		addEventListener "DOMMouseScroll", handle_scroll
		
		addEventListener "keydown", (e)=>
			# console.log e.keyCode
			return if e.target.tagName.match(/input|textarea|select|button/i)
			switch e.keyCode
				when 32, 80 # Space or P
					@toggleEditing()
				when 46 # Delete
					@delete()
				when 90 # Z
					if e.ctrlKey
						if e.shiftKey then @redo() else @undo()
				when 89 # Y
					@redo() if e.ctrlKey
				when 88 # X
					@cut() if e.ctrlKey
				when 67 # C
					@copy() if e.ctrlKey
				when 86 # V
					@paste() if e.ctrlKey
				when 65 # A
					@selectAll() if e.ctrlKey
	
	save: ->
		json = JSON.stringify(@world, null, "\t")
		if fs?
			fs.writeFileSync(@save_path, json)
		else
			localStorage["Skele2D World"] = json
	
	load: ->
		if fs?
			json = fs.readFileSync(@save_path)
		else
			json = localStorage["Skele2D World"]
		if json
			try
				@world.fromJSON(JSON.parse(json))
				return
			catch e
				@warn "Error loading saved world: #{e}", 10000
		# fall back to loading the default world
		req = new XMLHttpRequest()
		req.addEventListener "error", (e)=>
			@warn "Error loading default world: the network request failed.", 10000
		req.addEventListener "load", (e)=>
			if req.status isnt 200
				@warn "Error loading default world: #{req.status} #{req.statusText}", 10000
				return
			json = req.responseText
			if json
				try
					@world.fromJSON(JSON.parse(json))
					return
				catch error
					@warn "Error loading default world: #{error}", 10000
			else
				@warn "No default world loaded", 10000
		req.open("GET", "world.json")
		req.send()
	
	discardSave: ->
		if fs?
			fs.unlinkSync(@save_path)
		else
			delete localStorage["Skele2D World"]
	
	savePose: ->
		if @editing_entity_anim_name and @editing_entity_anim_name isnt "Current Pose"
			EntityClass = entityClasses[@editing_entity._class_]
			if @editing_entity_animation_frame_index?
				EntityClass.animations[@editing_entity_anim_name][@editing_entity_animation_frame_index] = @editing_entity.structure.getPose()
			else
				EntityClass.poses[@editing_entity_anim_name] = @editing_entity.structure.getPose()
			Entity.saveAnimations(EntityClass)
	
	toJSON: ->
		# TODO: make animation stuff undoable
		selected_entity_ids = (entity.id for entity in @selected_entities)
		editing_entity_id = @editing_entity?.id
		selected_point_names = []
		if @editing_entity?
			for point_name, point of @editing_entity.structure.points
				if point in @selected_points
					selected_point_names.push(point_name)
		{@world, selected_entity_ids, editing_entity_id, selected_point_names}
	
	fromJSON: (state)->
		@world.fromJSON(state.world)
		@hovered_entities = []
		@hovered_points = []
		@hovered_segments = []
		@selected_entities = []
		@selected_points = []
		for entity_id in state.selected_entity_ids
			entity = @world.getEntityByID(entity_id)
			@selected_entities.push entity if entity?
		@editing_entity = @world.getEntityByID(state.editing_entity_id)
		if @editing_entity?
			for point_name in state.selected_point_names
				@selected_points.push(@editing_entity.structure.points[point_name])
	
	undoable: (fn)->
		@undos.push(JSON.stringify(@))
		@redos = []
		if fn?
			do fn
			@save()
	
	undo: ->
		if @editing
			@undo_or_redo(@undos, @redos)
		else
			@toggleEditing()
			@undo()
			# TODO: undo view too
	
	redo: ->
		if @editing
			@undo_or_redo(@redos, @undos)
	
	undo_or_redo: (undos, redos)->
		return if undos.length is 0
		redos.push(JSON.stringify(@))
		@fromJSON(JSON.parse(undos.pop()))
		@save()
	
	selectAll: ->
		if @editing_entity
			@selected_points = (point for point_name, point of @editing_entity.structure.points)
		else
			@selected_entities = (entity for entity in @world.entities)
	
	selectAllSameType: ->
		types =
			if @editing_entity
				[@editing_entity._class_]
			else
				(entity._class_ for entity in @selected_entities)
		
		@finishEditingEntity()
		@selected_entities = (entity for entity in @world.entities when entity._class_ in types)
	
	delete: ->
		if @selected_points.length
			plural = @selected_points.length > 1
			original_redos = [@redos...]
			# Not using callback version so that it doesn't
			# save until it's verified that the entity can be drawn & stepped
			@undoable()

			for segment_name, segment of @editing_entity.structure.segments
				if (segment.a in @selected_points) or (segment.b in @selected_points)
					delete @editing_entity.structure.segments[segment_name]
			for point_name, point of @editing_entity.structure.points
				if point in @selected_points
					delete @editing_entity.structure.points[point_name]
			@selected_points = []
			@dragging_points = []

			dummy_ctx = document.createElement("canvas").getContext("2d")
			dummy_view = new View
			try
				@editing_entity.draw(dummy_ctx, dummy_view)
			catch e
				@undo()
				@redos = original_redos
				console?.warn?("Entity failed to draw after deletion, with", e)
				if plural
					alert("Entity needs one or more of those points to render")
				else
					alert("Entity needs that point to render")
				return
			try
				# Entity::step() is allowed to modify other entities,
				# so we need to save/restore the whole world state.
				# However, we also need to either preserve or update the reference to the entity being edited,
				# so that the visible entity's version of the structure doesn't desynchronize from the editor's.

				# TODO: I could also add a flag, either as a parameter to step() or globally,
				# that says whether or not it's safe to perform major side effects
				# such as saving the game when reaching a checkpoint,
				# playing a sound,
				# starting a cinematic that runs using setTimeout() rather than properties on entities (problematic for playing well with pausing anyways),
				# or causing a screen shake effect — things that are outside the world state.
				original_ent_def = JSON.parse(JSON.stringify(@editing_entity))
				original_world_state = JSON.parse(JSON.stringify(@world))
				@editing_entity.step(@world)
				@world.fromJSON(original_world_state)
				# world.fromJSON doesn't preserve the same instance of the Entity
				# Find the old new instance and replace it with the original with the same ID
				# Alternatively, something like this might work: @editing_entity = @world.getEntityByID(original_ent_def.id)
				# But I'd also need to update @selected_entities and @selected_points, maybe @hovered_entities and @hovered_points too...
				# This is ugly but hopefully robust
				for entity in @world.entities
					if entity.id is @editing_entity.id
						@world.entities.splice(@world.entities.indexOf(entity), 1, @editing_entity)
						break
				# and restore the entity's state
				@editing_entity.fromJSON(original_ent_def)
			catch e
				@undo()
				@redos = original_redos
				console?.warn?("Entity failed to step after deletion, with", e)
				if plural
					alert("Entity needs one or more of those points to step")
				else
					alert("Entity needs that point to step")
				return
			
			@save()
		else if @selected_entities.length
			@undoable =>
				for entity in @selected_entities
					# entity.destroy()
					entity.destroyed = true
					index = @world.entities.indexOf(entity)
					@world.entities.splice(index, 1) if index >= 0
				@selected_entities = []
				@finishEditingEntity()
	
	cut: ->
		@copy()
		@delete()
	
	copy: ->
		if @selected_points.length
			alert("Copying points is not supported")
			# clipboard.point_positions = {}
		else
			@clipboard.entities =
				for entity in @selected_entities
					json: JSON.stringify(entity)
	
	paste: ->
		if @editing_entity
			alert("Pasting points is not supported")
		else
			@undoable =>
				if not @clipboard.entities?.length
					@warn "Nothing on clipboard"
					return
				
				@selected_entities = []
				new_entities =
					for {json} in @clipboard.entities
						ent_def = JSON.parse(json)
						delete ent_def.id
						entity = Entity.fromJSON(ent_def)
						@world.entities.push(entity)
						@selected_entities.push(entity)
						entity
				
				centroids =
					for entity in new_entities
						centroid = {x: 0, y: 0}
						divisor = 0
						for point_name, point of entity.structure.points
							centroid.x += point.x
							centroid.y += point.y
							divisor += 1
						centroid.x /= divisor
						centroid.y /= divisor
						centroid_in_world = entity.toWorld(centroid)
						centroid_in_world
				
				center = {x: 0, y: 0}
				for centroid in centroids
					center.x += centroid.x
					center.y += centroid.y
				center.x /= centroids.length
				center.y /= centroids.length
				
				mouse_in_world = @view.toWorld(@mouse)
				
				for entity in new_entities
					entity.x += mouse_in_world.x - center.x
					entity.y += mouse_in_world.y - center.y
	
	toggleEditing: ->
		@undoable() if @editing
		@editing = not @editing
		@renderDOM()
	
	step: ->
		
		mouse_in_world = @view.toWorld(@mouse)
		
		if @mouse.LMB.released
			if @dragging_points.length or @tool_active
				@dragging_points = []
				@tool_active = no
				@savePose()
				@save()
			
			if @dragging_entities.length
				@save()
				for entity, i in @dragging_entities
					if entity.vx? and entity.vy?
						entity.vx = (mouse_in_world.x + @drag_offsets[i].x - entity.x) / 3
						entity.vy = (mouse_in_world.y + @drag_offsets[i].y - entity.y) / 3
				@dragging_entities = []
			
			if @selection_box
				if @editing_entity
					@selected_points = (entity for entity in @hovered_points)
				else
					@selected_entities = (entity for entity in @hovered_entities)
				@selection_box = null
		
		# min_grab_dist = (5 + 5 / Math.min(@view.scale, 1)) / 2
		# min_grab_dist = 8 / Math.min(@view.scale, 5)
		min_grab_dist = 8 / @view.scale
		# console.log @view.scale, min_grab_dist
		
		point_within_selection_box = (entity, point)=>
			relative_x1 = @selection_box.x1 - entity.x
			relative_y1 = @selection_box.y1 - entity.y
			relative_x2 = @selection_box.x2 - entity.x
			relative_y2 = @selection_box.y2 - entity.y
			relative_min_x = Math.min(relative_x1, relative_x2)
			relative_max_x = Math.max(relative_x1, relative_x2)
			relative_min_y = Math.min(relative_y1, relative_y2)
			relative_max_y = Math.max(relative_y1, relative_y2)
			relative_min_x <= point.x <= relative_max_x and
			relative_min_y <= point.y <= relative_max_y and
			relative_min_x <= point.x <= relative_max_x and
			relative_min_y <= point.y <= relative_max_y
		
		entity_within_selection_box = (entity)=>
			relative_x1 = @selection_box.x1 - entity.x
			relative_y1 = @selection_box.y1 - entity.y
			relative_x2 = @selection_box.x2 - entity.x
			relative_y2 = @selection_box.y2 - entity.y
			relative_min_x = Math.min(relative_x1, relative_x2)
			relative_max_x = Math.max(relative_x1, relative_x2)
			relative_min_y = Math.min(relative_y1, relative_y2)
			relative_max_y = Math.max(relative_y1, relative_y2)
			return false if Object.keys(entity.structure.segments).length is 0
			for segment_name, segment of entity.structure.segments
				unless (
					relative_min_x <= segment.a.x <= relative_max_x and
					relative_min_y <= segment.a.y <= relative_max_y and
					relative_min_x <= segment.b.x <= relative_max_x and
					relative_min_y <= segment.b.y <= relative_max_y
				)
					return false
			return true
		
		@view.center_x -= @view_drag_momentum.x
		@view.center_y -= @view_drag_momentum.y
		@view_to.center_x -= @view_drag_momentum.x
		@view_to.center_y -= @view_drag_momentum.y
		@view_drag_momentum.x *= 0.8
		@view_drag_momentum.y *= 0.8
		
		@dragging_points =
			for point in @dragging_points
				@editing_entity.structure.points[point.name]
		
		@selected_points =
			for point in @selected_points
				@editing_entity.structure.points[point.name]
		
		if @view_drag_start_in_world
			if @mouse.MMB.down
				@view.center_x -= mouse_in_world.x - @view_drag_start_in_world.x
				@view.center_y -= mouse_in_world.y - @view_drag_start_in_world.y
				@view_to.center_x = @view.center_x
				@view_to.center_y = @view.center_y
				@view_drag_momentum.x = 0
				@view_drag_momentum.y = 0
			else
				@view_drag_momentum.x = mouse_in_world.x - @view_drag_start_in_world.x
				@view_drag_momentum.y = mouse_in_world.y - @view_drag_start_in_world.y
				@view_drag_start_in_world = null
		else if @mouse.MMB.pressed
			@view_drag_start_in_world = {x: mouse_in_world.x, y: mouse_in_world.y}
		else if @mouse.double_clicked
			# TODO: reject double clicks where the first click was not on the same entity
			# TODO: reject double click and drag
			if @hovered_entities.length
				if @hovered_entities[0] in @selected_entities
					@editEntity(@hovered_entities[0])
			else if @hovered_segments.length
				# Add a point in the middle of the hovered segment
				segment = @hovered_segments[0]
				if @editing_entity?.structure instanceof PolygonStructure
					vertices = @editing_entity.structure.toJSON().points
					index_a = Object.values(@editing_entity.structure.points).indexOf(segment.a)
					index_b = Object.values(@editing_entity.structure.points).indexOf(segment.b)
					index = Math.min(index_a, index_b) + 1
					vertices.splice(index, 0, {
						x: segment.a.x + (segment.b.x - segment.a.x) / 2
						y: segment.a.y + (segment.b.y - segment.a.y) / 2
					})
					@editing_entity.structure.fromJSON({points: vertices})
			else
				# TODO: don't exit editing mode if the entity being edited is hovered
				# except there needs to be a visual indication of hover for the editing entity
				# (there would be with the cursor if you could drag segments)
				# unless @editing_entity? and @distanceToEntity(@editing_entity, mouse_in_world) < min_grab_dist
				@finishEditingEntity()
		else if @dragging_entities.length
			for entity, i in @dragging_entities
				entity.x = mouse_in_world.x + @drag_offsets[i].x
				entity.y = mouse_in_world.y + @drag_offsets[i].y
		else if @dragging_points.length
			local_mouse_position = @editing_entity.fromWorld(mouse_in_world)
			for point, i in @dragging_points
				point.x = local_mouse_position.x + @drag_offsets[i].x
				point.y = local_mouse_position.y + @drag_offsets[i].y
			@editing_entity.structure.signalChange?()
		else if @dragging_segments.length
			# TODO
		else if @selection_box
			@selection_box.x2 = mouse_in_world.x
			@selection_box.y2 = mouse_in_world.y
			if @editing_entity
				@hovered_points = (point for point_name, point of @editing_entity.structure.points when point_within_selection_box(@editing_entity, point))
				# This causes adding points with double click not to work
				# and it's not used for anything at the moment
				# @hovered_segments = (segment for segment_name, segment of @editing_entity.structure.segments when segment.a in @hovered_points and segment.b in @hovered_points)
			else
				@hovered_entities = (entity for entity in @world.entities when entity_within_selection_box(entity))
		else if @grab_start
			if @mouse.LMB.down
				if distance(@mouse, @grab_start) > 2
					if @selected_points.length
						@dragPoints(@selected_points, @grab_start_in_world)
					else if @selected_entities.length
						@dragEntities(@selected_entities, @grab_start_in_world)
					@grab_start = null
			else
				@grab_start = null
		else if @tool_active
			if @mouse.LMB.down
				# if @sculpt_additive
					
				# else
				# 	
				mouse_world_delta_x = mouse_in_world.x - @previous_mouse_world_x
				mouse_world_delta_y = mouse_in_world.y - @previous_mouse_world_y
				run_tool(@tool, @editing_entity, mouse_in_world, mouse_world_delta_x, mouse_world_delta_y, @brush_size)
			else
				@tool_active = no
		else
			@hovered_entities = []
			@hovered_points = []
			@hovered_segments = []
			if @editing_entity
				local_mouse_position = @editing_entity.fromWorld(mouse_in_world)
				if @tool is "sculpt"
					@sculpt_additive = @editing_entity.structure.pointInPolygon?(local_mouse_position)
				else if @tool is "select"
					closest_dist = Infinity
					for point_name, point of @editing_entity.structure.points
						dist = distance(local_mouse_position, point)
						if dist < min_grab_dist and dist < closest_dist
							closest_dist = dist
							@hovered_points = [point]
					unless @hovered_points.length
						closest_dist = Infinity
						for segment_name, segment of @editing_entity.structure.segments
							dist = distanceToLineSegment(local_mouse_position, segment.a, segment.b)
							if dist < (segment.width ? 5) and dist < closest_dist
								closest_dist = dist
								@hovered_segments = [segment]
			else
				closest_dist = Infinity
				closest_entity = null
				for entity in @world.entities
					dist = @distanceToEntity(entity, mouse_in_world)
					if dist < min_grab_dist and (dist < closest_dist or (entity not instanceof Terrain and closest_entity instanceof Terrain))
						closest_entity = entity
						closest_dist = dist
				if closest_entity?
					@hovered_entities = [closest_entity]
			
			if @mouse.LMB.pressed
				@dragging_points = []
				@dragging_segments = []
				
				if @editing_entity and @tool isnt "select"
					@undoable()
					@tool_active = yes
				else
					if @hovered_points.length
						if @hovered_points[0] in @selected_points
							@grabPoints(@selected_points, mouse_in_world)
						else
							@grabPoints(@hovered_points, mouse_in_world)
					else
						@selected_points = []
						
						if @hovered_entities.length
							if @hovered_entities[0] in @selected_entities
								@grabEntities(@selected_entities, mouse_in_world)
							else
								@grabEntities(@hovered_entities, mouse_in_world)
						else
							@selection_box = {x1: mouse_in_world.x, y1: mouse_in_world.y, x2: mouse_in_world.x, y2: mouse_in_world.y}
		
		if @editing_entity
			if @editing_entity.structure instanceof BoneStructure
			# TODO: and if there isn't an animation frame loaded
				@editing_entity.structure.stepLayout() for [0..250]
				# TODO: save afterwards at some point

		@previous_mouse_world_x = mouse_in_world.x
		@previous_mouse_world_y = mouse_in_world.y
	
	editEntity: (entity)->
		@editing_entity = entity
		@selected_entities = [entity]
	
	finishEditingEntity: ->
		@editing_entity = null
		@selected_entities = []
		@selected_points = []
		@dragging_entities = []
		@dragging_points = []
		@tool_active = no
	
	distanceToEntity: (entity, from_point_in_world)->
		from_point = entity.fromWorld(from_point_in_world)
		closest_dist = Infinity
		
		for segment_name, segment of entity.structure.segments
			dist = distanceToLineSegment(from_point, segment.a, segment.b)
			# dist = Math.max(0, dist - segment.width / 2) if segment.width?
			closest_dist = Math.min(closest_dist, dist)
			
		for point_name, point of entity.structure.points
			dist = distance(from_point, point)
			# dist = Math.max(0, dist - segment.radius) if segment.radius?
			closest_dist = Math.min(closest_dist, dist)
		
		closest_dist
	
	grabPoints: (points, mouse_in_world)->
		if @editing_entity and @editing_entity_anim_name is "Current Pose"
			EntityClass = entityClasses[@editing_entity._class_]
			if EntityClass.poses? or EntityClass.animations?
				@warn "No pose is selected. Select a pose to edit."
				return
		
		@grab_start = {x: @mouse.x, y: @mouse.y}
		@grab_start_in_world = mouse_in_world
		@selected_points = (point for point in points)
		local_mouse_position = @editing_entity.fromWorld(mouse_in_world)
		@drag_offsets =
			for point in @dragging_points
				x: point.x - local_mouse_position.x
				y: point.y - local_mouse_position.y

	dragPoints: (points, mouse_in_world)->
		@selected_points = (point for point in points)
		@undoable()
		@dragging_points = (point for point in points)
		local_mouse_position = @editing_entity.fromWorld(mouse_in_world)
		@drag_offsets =
			for point in @dragging_points
				x: point.x - local_mouse_position.x
				y: point.y - local_mouse_position.y
	
	grabEntities: (entities, mouse_in_world)->
		@grab_start = {x: @mouse.x, y: @mouse.y}
		@grab_start_in_world = mouse_in_world
		@selected_entities = (entity for entity in entities)
		@drag_offsets =
			for entity in @dragging_entities
				if mouse_in_world?
					x: entity.x - mouse_in_world.x
					y: entity.y - mouse_in_world.y
				else
					{x: 0, y: 0}
	
	dragEntities: (entities, mouse_in_world)->
		@selected_entities = (entity for entity in entities)
		@undoable()
		@dragging_entities = (entity for entity in entities)
		@drag_offsets =
			for entity in @dragging_entities
				if mouse_in_world?
					x: entity.x - mouse_in_world.x
					y: entity.y - mouse_in_world.y
				else
					{x: 0, y: 0}
	
	draw: (ctx, view)->
		
		draw_points = (entity, radius, fillStyle)=>
			for point_name, point of entity.structure.points
				ctx.beginPath()
				ctx.arc(point.x, point.y, radius / view.scale, 0, TAU)
				# ctx.lineWidth = 1 / view.scale
				# ctx.strokeStyle = "black"
				# ctx.stroke()
				ctx.fillStyle = fillStyle
				ctx.fill()
				# ctx.fillText(point_name, point.x + radius * 2, point.y)
		
		draw_segments = (entity, lineWidth, strokeStyle)=>
			for segment_name, segment of entity.structure.segments
				ctx.beginPath()
				ctx.moveTo(segment.a.x, segment.a.y)
				ctx.lineTo(segment.b.x, segment.b.y)
				ctx.lineWidth = lineWidth / view.scale
				ctx.lineCap = "round"
				ctx.strokeStyle = strokeStyle
				ctx.stroke()
		
		if @editing_entity
			ctx.save()
			ctx.translate(@editing_entity.x, @editing_entity.y)
			draw_points(@editing_entity, 3, "rgba(255, 0, 0, 1)")
			draw_segments(@editing_entity, 1, "rgba(255, 170, 0, 1)")
			ctx.restore()
		
		for entity in @selected_entities when entity isnt @editing_entity
			ctx.save()
			ctx.translate(entity.x, entity.y)
			draw_points(entity, 2, "rgba(255, 170, 0, 1)")
			draw_segments(entity, 1, "rgba(255, 170, 0, 1)")
			ctx.restore()
		
		for entity in @hovered_entities when entity not in @selected_entities
			ctx.save()
			ctx.translate(entity.x, entity.y)
			draw_points(entity, 2, "rgba(255, 170, 0, 0.2)")
			draw_segments(entity, 1, "rgba(255, 170, 0, 0.5)")
			ctx.restore()
		
		if @editing_entity?
			if @tool in ["sculpt", "roughen", "smooth", "paint"]
				mouse_in_world = @view.toWorld(@mouse)
				ctx.beginPath()
				# ctx.arc(mouse_in_world.x, mouse_in_world.y, @brush_size / view.scale, 0, TAU)
				ctx.arc(mouse_in_world.x, mouse_in_world.y, @brush_size, 0, TAU)
				# ctx.lineWidth = 1.5 / view.scale
				# ctx.strokeStyle = "rgba(255, 170, 0, 1)"
				# ctx.stroke()
				ctx.fillStyle = "rgba(0, 155, 255, 0.1)"
				ctx.strokeStyle = "rgba(0, 155, 255, 0.8)"
				ctx.lineWidth = 1 / view.scale
				ctx.fill()
				ctx.stroke()
			else
				ctx.save()
				ctx.translate(@editing_entity.x, @editing_entity.y)
				# draw_points(@selected_points, 2, "rgba(255, 170, 0, 0.2)")
				for point in @selected_points
					ctx.beginPath()
					ctx.arc(point.x, point.y, 3 / view.scale, 0, TAU)
					ctx.fillStyle = "rgba(255, 0, 0, 1)"
					ctx.fill()
					ctx.lineWidth = 1.5 / view.scale
					ctx.strokeStyle = "rgba(255, 170, 0, 1)"
					ctx.stroke()
				ctx.restore()
		
		for entity in @selected_entities
			ctx.strokeStyle = "rgba(255, 170, 0, 1)"
			bbox = entity.bbox()
			ctx.lineWidth = 1 / view.scale
			ctx.strokeRect(bbox.x, bbox.y, bbox.width, bbox.height)
		
		if @selection_box?
			ctx.save()
			ctx.beginPath()
			ctx.translate(0.5, 0.5) if view.scale is 1
			ctx.rect(@selection_box.x1, @selection_box.y1, @selection_box.x2 - @selection_box.x1, @selection_box.y2 - @selection_box.y1)
			ctx.fillStyle = "rgba(0, 155, 255, 0.1)"
			ctx.strokeStyle = "rgba(0, 155, 255, 0.8)"
			ctx.lineWidth = 1 / view.scale
			ctx.fill()
			ctx.stroke()
			ctx.restore()
	
	warn: (message, timeout=2000)->
		@warning_message = message
		@show_warning = yes
		@renderDOM()
		clearTimeout @warning_tid
		@warning_tid = setTimeout =>
			@show_warning = no
			@renderDOM()
		, timeout
	
	renderDOM: ->
		react_root = E ".editor",
			E EntitiesBar, editor: @, ref: (@entities_bar)=>
			E AnimBar, editor: @, ref: (@anim_bar)=>
			E ToolsBar, editor: @, ref: (@tools_bar)=>
			E ".warning",
				class: ("show" if @show_warning)
				@warning_message
		
		ReactDOM.render(react_root, @react_root_el)
	
	updateGUI: ->
		unless @editing_entity
			@editing_entity_anim_name = "Current Pose"
			@editing_entity_animation_frame_index = null
		show = @editing
		@entities_bar.update(show)
		@anim_bar.update(show)
		@tools_bar.update(show)
