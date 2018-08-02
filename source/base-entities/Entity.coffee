
fs = require? "fs"
path = require? "path"
# XXX: hack for webpack
# TODO: use ifdef conditionals or something
fs = null if not fs.readFileSync
path = null if not path.join

Pose = require "../structure/Pose.coffee"
BoneStructure = require "../structure/BoneStructure.coffee"
{entity_classes} = require "../helpers.coffee"

module.exports = class Entity
	constructor: ->
		@structure = new BoneStructure
		@x = 0
		@y = 0
		@id = uuid()
		
		@bbox_padding = 2
		# TODO: depth system
		# @drawing_pieces = {}
		
		@_class_ = @constructor.name
	
	@initAnimation: (EntityClass)->
		EntityClass.poses = {}
		EntityClass.animations = {}
		EntityClass.animation_json_path = "./animations/#{EntityClass.name}.json"
		Entity.loadAnimations(EntityClass)
		
	@loadAnimations: (EntityClass)->
		animationsFromJSON = ({poses, animations})->
			EntityClass.poses = {}
			EntityClass.animations = {}
			for pose_name, pose of poses
				EntityClass.poses[pose_name] = new Pose(pose)
			for animation_name, animation of animations
				EntityClass.animations[animation_name] = (new Pose(pose) for pose in animation)
		
		if fs?
			try
				json = fs.readFileSync(EntityClass.animation_json_path)
			catch e
				throw e unless e.code is "ENOENT"
		else
			json = localStorage["Skele2D #{EntityClass.name} animations"]
		if json
			animationsFromJSON(JSON.parse(json)) if json
		else
			req = new XMLHttpRequest
			req.addEventListener "load", (e)=>
				json = req.responseText
				animationsFromJSON(JSON.parse(json)) if json
			req.open("GET", EntityClass.animation_json_path)
			req.send()
	
	@saveAnimations: (EntityClass)->
		{poses, animations} = EntityClass
		json = JSON.stringify({poses, animations}, null, "\t")
		if fs?
			try
				fs.mkdirSync(path.dirname(EntityClass.animation_json_path))
			catch e
				throw e unless e.code is "EEXIST"
			fs.writeFileSync(EntityClass.animation_json_path, json)
		else
			localStorage["Skele2D #{EntityClass.name} animations"] = json
	
	@fromJSON: (def)->
		unless typeof def._class_ is "string"
			console.error "Erroneous entity definition:", def
			throw new Error "Expected entity to have a string _class_, _class_ is #{def._class_}"
		unless entity_classes[def._class_]
			throw new Error "Entity class '#{def._class_}' does not exist"
		entity = new entity_classes[def._class_]
		entity.fromJSON(def)
		entity
	
	fromJSON: (def)->
		if def._class_ isnt @_class_
			throw new Error "Tried to initialize #{@_class_} entity from JSON with _class_ #{JSON.stringify(def._class_)}"
		for k, v of def when k isnt "_class_"
			if @[k]?.fromJSON
				@[k].fromJSON(v)
			else
				@[k] = v
	
	resolveReferences: (world)->
		if @_refs_
			for k, id of @_refs_
				@[k] = world.getEntityByID(id)
			delete @_refs_
	
	toJSON: ->
		obj = {}
		for k, v of @ when k isnt "_refs_"
			if v instanceof Entity
				obj._refs_ ?= {}
				obj._refs_[k] = v.id
			else
				obj[k] = v
		obj
	
	toWorld: (point)->
		x: point.x + @x
		y: point.y + @y
	
	fromWorld: (point)->
		x: point.x - @x
		y: point.y - @y
	
	bbox: ->
		min_point = {x: +Infinity, y: +Infinity}
		max_point = {x: -Infinity, y: -Infinity}
		for point_name, point of @structure.points
			min_point.x = Math.min(min_point.x, point.x)
			min_point.y = Math.min(min_point.y, point.y)
			max_point.x = Math.max(max_point.x, point.x)
			max_point.y = Math.max(max_point.y, point.y)
		min_point.x = 0 unless isFinite(min_point.x)
		min_point.y = 0 unless isFinite(min_point.y)
		max_point.x = 0 unless isFinite(max_point.x)
		max_point.y = 0 unless isFinite(max_point.y)
		min_point.x -= @bbox_padding
		min_point.y -= @bbox_padding
		max_point.x += @bbox_padding
		max_point.y += @bbox_padding
		min_point_in_world = @toWorld(min_point)
		max_point_in_world = @toWorld(max_point)
		x: min_point_in_world.x
		y: min_point_in_world.y
		width: max_point_in_world.x - min_point_in_world.x
		height: max_point_in_world.y - min_point_in_world.y
	
	# animate: ()->
	# 	@structure.setPose(Pose.lerp(various_poses))
	
	initLayout: ->
		EntityClass = @constructor
		if EntityClass.poses
			default_pose = EntityClass.poses["Default"] ? EntityClass.poses["Stand"] ? EntityClass.poses["Standing"] ? EntityClass.poses["Idle"]
			if default_pose
				@structure.setPose(default_pose)
				return
		ys = {}
		y = 0
		for point_name, point of @structure.points
			side = point_name.match(/left|right/)?[0]
			if side
				sideless_point_name = point_name.replace(/left|right/, "")
				if ys[sideless_point_name]
					y = ys[sideless_point_name]
				else
					y += 10
					ys[sideless_point_name] = y
				if side is "left"
					point.x = -5.5
				if side is "right"
					point.x = +5.5
				point.x *= 0.7 if point_name.match(/lower/)
			point.y = y
		
		for [0..2000]
			@structure.stepLayout(center: yes, repel: yes)
		for [0..4000]
			@structure.stepLayout()
	
	step: (world)->
	draw: (ctx)->
	
	# TODO: function to call into the depth system
	# drawStructure: (drawing_functions)->
	# 	for point_name, fn of drawing_functions.points
	# 		fn(@structure.points[point_name])
	# 	for segment_name, fn of drawing_functions.segments
	# 		fn(@structure.segments[segment_name])
