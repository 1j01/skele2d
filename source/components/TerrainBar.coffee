import ReactDOM from "react-dom"
import {Component} from "react"
import E from "react-script"

import Terrain from "../base-entities/Terrain.coffee"

export default class TerrainBar extends Component
	constructor: ->
		super()
		@state = {visible: no}
	
	render: ->
		{editor} = @props
		{visible} = @state
		
		{sculpt_mode, brush_size} = editor
		
		E ".bar.sidebar.terrain-bar", class: {visible},
			E "h1", "Terrain"
			E ".terrain-tools",
				E "label.mdl-switch.mdl-js-switch.mdl-js-ripple-effect",
					# for: "toggle-sculpt-mode", ref: (@sculpt_mode_switch)=>
					# E "input.mdl-switch__input#toggle-sculpt-mode",
					ref: (@sculpt_mode_switch)=>
					E "input.mdl-switch__input",
						type: "checkbox", checked: sculpt_mode
						# FIXME: Warning: TerrainBar is changing a uncontrolled input of type checkbox to be controlled. Input elements should not switch from uncontrolled to controlled (or vice versa). Decide between using a controlled or uncontrolled input element for the lifetime of the component.
						# checked: false is apparently interpreted by ReactScript as leaving off the checked attribute
						onChange: (e)=>
							editor.sculpt_mode = e.target.checked
							editor.renderDOM()
					E "span.mdl-switch__label", "Sculpt Mode"
				E "label",
					E "span.mdl-checkbox__label.mdl-slider__label", "Brush Size"
					E "input.mdl-slider.mdl-js-slider",
						type: "range", min: 0, max: 100, value: brush_size, tabIndex: 0
						disabled: not sculpt_mode
						style: minWidth: 200
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
		
		# TODO: ducktype? or rather replace the whole UI with a more general toolbox
		show = show and editing_entity instanceof Terrain
		
		@setState visible: show
