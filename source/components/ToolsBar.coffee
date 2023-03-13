import React from "react"
import ReactDOM from "react-dom"
import {Component} from "react"
import E from "react-script"
import selectIcon from "../icons/select.svg"
import pushIcon from "../icons/push-arrows-in-circle.svg"
import roughenIcon from "../icons/roughen.svg"
import smoothIcon from "../icons/smooth.svg"
import paintIcon from "../icons/brush.svg"

import Terrain from "../base-entities/Terrain.coffee"

export default class ToolsBar extends Component
	constructor: ->
		super()
		@state = {visible: no}
		@tools = [
			{name: "select", icon: selectIcon}
			{name: "sculpt", icon: pushIcon}
			{name: "roughen", icon: roughenIcon}
			{name: "smooth", icon: smoothIcon}
			{name: "paint", icon: paintIcon}
		]
		for tool in @tools
			tool.buttonRef = React.createRef()
	
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
						disabled: name is "paint" and not (editor.editing_entity instanceof Terrain)
						onClick: (e)=>
							editor.tool = name
							editor.renderDOM()
						# E "i.material-icons", E "i.material-symbols-outlined", icon
						E "img", src: icon
						" "
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
