
class @Mouse
	constructor: (canvas, @view)->
		@x = -Infinity
		@y = -Infinity
		@LMB = {down: no, pressed: no, released: no}
		@MMB = {down: no, pressed: no, released: no}
		@RMB = {down: no, pressed: no, released: no}
		@double_clicked = no
		
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
