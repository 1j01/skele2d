
class @TerrainBar extends React.Component
	constructor: ->
		super
		@state = {visible: no}
	
	render: ->
		{editor} = @props
		{visible} = @state
		
		{sculpt_mode, brush_size} = editor
		# console.log sculpt_mode, brush_size
		
		E ".bar.sidebar.terrain-bar", class: {visible},
			E "h1", "Terrain"
			E ".terrain-tools",
				E "label.mdl-switch.mdl-js-switch.mdl-js-ripple-effect",
					# for: "toggle-sculpt-mode", ref: (@sculpt_mode_switch)=>
					# E "input.mdl-switch__input#toggle-sculpt-mode",
					ref: (@sculpt_mode_switch)=>
					E "input.mdl-switch__input",
						type: "checkbox", checked: sculpt_mode
						onChange: (e)=>
							editor.sculpt_mode = e.target.checked
							editor.renderDOM()
					E "span.mdl-switch__label", "Sculpt Mode"
				E "label",
					E "span.mdl-checkbox__label.mdl-slider__label", "Brush Size"
					E "input.mdl-slider.mdl-js-slider",
						type: "range", min: 0, max: 100, value: brush_size, tabindex: 0
						disabled: not sculpt_mode
						ref: (@brush_size_slider)=>
						onChange: (e)=>
							editor.brush_size = e.target.value
							editor.renderDOM()
	
	componentDidMount: ->
		componentHandler.upgradeElement(ReactDOM.findDOMNode(@sculpt_mode_switch))
		componentHandler.upgradeElement(ReactDOM.findDOMNode(@brush_size_slider))
	
	update: (show)=>
		{editor} = @props
		{editing_entity} = editor
		
		show = show and editing_entity instanceof Terrain
		
		@setState visible: show
