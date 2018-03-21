
seedrandom("A world")

world = new World

terrain = new Snow
world.entities.push terrain
terrain.x = 0
terrain.y = 0
terrain.generate()

canvas = document.createElement("canvas")
document.body.appendChild(canvas)
ctx = canvas.getContext("2d")

@view = new View
@mouse = new Mouse(canvas, view)

@editor = new Editor(world, view, canvas)
try
	editor.load()
catch e
	console?.error? "Failed to load save:", e

try
	view.center_x_to = view.center_x = parseFloat(localStorage.view_center_x) unless isNaN(localStorage.view_center_x)
	view.center_y_to = view.center_y = parseFloat(localStorage.view_center_y) unless isNaN(localStorage.view_center_y)
	view.scale_to = view.scale = parseFloat(localStorage.view_scale) unless isNaN(localStorage.view_scale)

setInterval ->
	if editor.editing
		# TODO: should probably only save if you pan/zoom
		localStorage.view_center_x = view.center_x
		localStorage.view_center_y = view.center_y
		localStorage.view_scale = view.scale_to
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
		
		# TODO: allow margin of offcenterednses
		# player = world.getEntitiesOfType(Player)[0]
		# view.center_x_to = player.x
		# view.center_y_to = player.y
	
	view.width = canvas.width
	view.height = canvas.height
	
	view.step()
	editor.step() if editor.editing
	mouse.endStep()
	
	world.drawBackground(ctx, view)
	ctx.save()
	ctx.translate(canvas.width / 2, canvas.height / 2)
	ctx.scale(view.scale, view.scale)
	ctx.translate(-view.center_x, -view.center_y)
	
	world.draw(ctx, view)
	editor.draw(ctx, view) if editor.editing
	
	ctx.restore()
	
	editor.updateGUI()
	
	# keyboard.endStep()
