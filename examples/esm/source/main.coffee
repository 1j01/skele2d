
import {View, Mouse, Editor} from "skele2d"
import World from "./World.coffee"
import Rock from "./entities/terrain/Rock.coffee"
import Snow from "./entities/terrain/Snow.coffee"
# import keyboard from "./keyboard.coffee"

Math.seedrandom("A world")

world = new World

terrain = new Snow
world.entities.push terrain
terrain.x = 0
terrain.y = 0
terrain.generate()

canvas = document.createElement("canvas")
document.body.appendChild(canvas)
ctx = canvas.getContext("2d")

view = new View
view_to = new View
view_smoothness = 7
mouse = new Mouse(canvas)

editor = new Editor(world, view, view_to, canvas, mouse)
try
	editor.load()
catch e
	console?.error? "Failed to load save:", e

try
	view_to.center_x = view.center_x = parseFloat(localStorage.view_center_x) unless isNaN(localStorage.view_center_x)
	view_to.center_y = view.center_y = parseFloat(localStorage.view_center_y) unless isNaN(localStorage.view_center_y)
	view_to.scale = view.scale = parseFloat(localStorage.view_scale) unless isNaN(localStorage.view_scale)

setInterval ->
	if editor.editing
		# TODO: should probably only save if you pan/zoom
		localStorage.view_center_x = view.center_x
		localStorage.view_center_y = view.center_y
		localStorage.view_scale = view_to.scale
, 200

do animate = ->
	return if window.CRASHED
	requestAnimationFrame(animate)
	
	canvas.width = innerWidth unless canvas.width is innerWidth
	canvas.height = innerHeight unless canvas.height is innerHeight
	
	ctx.clearRect(0, 0, canvas.width, canvas.height)
	
	if editor.editing and (editor.entities_bar.hovered_cell or ((editor.hovered_points.length or editor.hovered_entities.length) and not editor.selection_box))
		canvas.classList.add("grabbable")
	else
		canvas.classList.remove("grabbable")
	
	unless editor.editing
		for entity in world.entities # when entity isnt editor.editing_entity and entity not in editor.dragging_entities
			entity.step(world)
		
		# TODO: allow margin of offcenteredness
		# player = world.getEntitiesOfType(Player)[0]
		# view_to.center_x = player.x
		# view_to.center_y = player.y
	
	view.width = canvas.width
	view.height = canvas.height
	
	view.easeTowards(view_to, view_smoothness)
	editor.step() if editor.editing
	mouse.resetForNextStep()
	
	world.drawBackground(ctx, view)
	ctx.save()
	ctx.translate(canvas.width / 2, canvas.height / 2)
	ctx.scale(view.scale, view.scale)
	ctx.translate(-view.center_x, -view.center_y)
	
	world.draw(ctx, view)
	editor.draw(ctx, view) if editor.editing
	
	ctx.restore()
	
	editor.updateGUI()
	
	# keyboard.resetForNextStep()
