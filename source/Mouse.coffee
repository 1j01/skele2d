
class @Mouse
	constructor: (canvas, @view)->
		@x = -Infinity
		@y = -Infinity
		@LMB = {down: no, pressed: no, released: no}
		@MMB = {down: no, pressed: no, released: no}
		@RMB = {down: no, pressed: no, released: no}
		@double_clicked = no
		
		# TODO: maybe have an init / initListeners / addListeners method?
		# doesn't seem good to add listeners in a constructor
		addEventListener "mousemove", (e)=>
			@x = e.clientX
			@y = e.clientY
		
		canvas.addEventListener "mousedown", (e)=>
			MB = @["#{"LMR"[e.button]}MB"]
			MB.down = yes
			MB.pressed = yes
		
		addEventListener "mouseup", (e)=>
			MB = @["#{"LMR"[e.button]}MB"]
			MB.down = no
			MB.released = yes
		
		canvas.addEventListener "dblclick", (e)=>
			MB = @["#{"LMR"[e.button]}MB"]
			MB.pressed = yes
			@double_clicked = yes
	
	# TODO: Is there something better that can be done here?
	# Currently Mouse requires a view, just to provide this convenience method.
	# Is it worth it? ...Looks like it's used 3 times. Not worth it. Not worth it!
	toWorld: ->
		@view.toWorld(@)
	
	endStep: ->
		@LMB.pressed = no
		@MMB.pressed = no
		@RMB.pressed = no
		@LMB.released = no
		@MMB.released = no
		@RMB.released = no
		@double_clicked = no
