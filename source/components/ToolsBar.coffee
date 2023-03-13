import React from "react"
import ReactDOM from "react-dom"
import {Component} from "react"
import E from "react-script"

import Terrain from "../base-entities/Terrain.coffee"

export default class ToolsBar extends Component
	constructor: ->
		super()
		@state = {visible: no}
		@tools = [
			{name: "select", icon: "arrow_selector_tool", buttonRef: React.createRef()}
			{name: "sculpt", icon: "touch_app", buttonRef: React.createRef()}
			{name: "roughen", icon: "floor", buttonRef: React.createRef()}
			{name: "smooth", icon: "waves", buttonRef: React.createRef()}
			{name: "paint", icon: "brush", buttonRef: React.createRef()}
		]
	
	render: ->
		{editor} = @props
		{visible} = @state
		
		{tool, brush_size} = editor
		
		E ".bar.tools-bar", class: {visible},
			E ".tools",
				@tools.map ({name, icon, buttonRef}, i)=>
					# E "button.mdl-button.mdl-js-button.mdl-button--icon.mdl-button--colored",
					E "button.mdl-button.mdl-js-button.mdl-button--colored",
						key: i
						ariaPressed: name is editor.tool
						ref: buttonRef
						onClick: (e)=>
							editor.tool = name
							editor.renderDOM()
						# E "i.material-icons", E "i.material-symbols-outlined", icon
						name
			E ".tool-options",
				E "label",
					E "span.mdl-checkbox__label.mdl-slider__label", "Brush Size"
					E "input.mdl-slider.mdl-js-slider",
						type: "range", min: 0, max: 100, value: brush_size, tabIndex: 0
						disabled: tool not in ["sculpt", "roughen", "smooth", "paint"]
						style: minWidth: 200
						ref: (@brush_size_slider)=>
						onChange: (e)=>
							editor.brush_size = e.target.value
							editor.renderDOM()
	
	componentDidMount: ->
		componentHandler.upgradeElement(ReactDOM.findDOMNode(@brush_size_slider))
		for tool in @tools
			componentHandler.upgradeElement(ReactDOM.findDOMNode(tool.buttonRef.current))
	
	update: (show)=>
		{editor} = @props
		{editing_entity} = editor
		
		show = show and editing_entity
		
		@setState visible: show
