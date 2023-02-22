
export default class View
	constructor: ->
		@center_x = 0
		@center_y = 0
		@scale = 1
		@width = 1
		@height = 1
	
	easeTowards: (to_view, smoothness, delta_time=1)->
		@center_x += (to_view.center_x - @center_x) / (1 + smoothness / to_view.scale * @scale) * delta_time
		@center_y += (to_view.center_y - @center_y) / (1 + smoothness / to_view.scale * @scale) * delta_time
		@scale += (to_view.scale - @scale) / (1 + smoothness) * delta_time
	
	testRect: (x, y, width, height, padding=0)->
		@center_x - @width / 2 / @scale - padding <= x <= @center_x + @width / 2 / @scale + padding and
		@center_y - @height / 2 / @scale - padding <= y <= @center_y + @height / 2 / @scale + padding
	
	toWorld: (point)->
		# x: (point.x + @center_x - @width / 2) / @scale
		# y: (point.y + @center_y - @height / 2) / @scale
		x: (point.x - @width / 2) / @scale + @center_x
		y: (point.y - @height / 2) / @scale + @center_y
	
	fromWorld: (point)->
		# x: point.x * @scale + @center_x + @width / 2
		# y: point.y * @scale + @center_y + @height / 2
		x: (point.x - @center_x) * @scale + @width / 2
		y: (point.y - @center_y) * @scale + @height / 2
