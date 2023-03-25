
# awkward component Anim represents a pose OR an animation OR an animation frame (which is an unnamed pose)

import {Component} from "react"
import ReactDOM from "react-dom"
import E from "react-script"
import EntityPreview from "./EntityPreview.coffee"
import Entity from "../base-entities/Entity.coffee"
import renameObjectKey from "../rename-object-key.coffee"

export default class Anim extends Component
	constructor: ->
		super()
	
	render: ->
		{entity, EntityClass, name, type_of_anims, selected, select, delete_item, update, editor} = @props
		max_width = 200
		max_height = 100
		E "article",
			class: {selected}
			onClick: (e)=>
				return if e.defaultPrevented
				select()
				update()
			if name is "Current Pose"
				E "h1.name", name
			else
				# TODO: for animation-frames, instead of a textfield have a reorder handle and a duration control
				# well, a reorder handle might be nice for the other anims too
				E ".title-bar",
					style: {maxWidth: max_width}
					E ".mdl-textfield.mdl-js-textfield.name",
						ref: (@mdl_textfield_el)=>
						E "input.mdl-textfield__input",
							value: name.replace(/TEMP_NAME_SENTINEL\d*$/, "")
							ref: (@name_input_el)=>
							dataInvalidNotUnique: name.includes("TEMP_NAME_SENTINEL")
							required: true
							onFocus: (e)=>
								@name_input_el.reportValidity()
							onChange: (e)=>
								new_name = e.target.value
								# TODO: use error classes and messages instead of intrusive alerts
								if type_of_anims is "animations"
									if EntityClass.animations[new_name]
										# editor.warn("There's already an animation with the name '#{new_name}'")
										# setCustomValidity is better, more contextual.
										@name_input_el.setCustomValidity("There's already an animation with the name '#{new_name}'")
										needs_temp_name = true
								else if type_of_anims is "poses"
									if EntityClass.poses[new_name]
										# editor.warn("There's already a pose with the name '#{new_name}'")
										@name_input_el.setCustomValidity("There's already a pose with the name '#{new_name}'")
										needs_temp_name = true
								else
									alert("This shouldn't happen. Unknown type: #{type_of_anims}")
									return

								if needs_temp_name
									new_name += "TEMP_NAME_SENTINEL"
									while EntityClass[type_of_anims][new_name]
										new_name += "1"
								else
									@name_input_el.setCustomValidity("")
								@name_input_el.reportValidity()

								anims_object = EntityClass[type_of_anims]
								renameObjectKey(anims_object, name, new_name)
								editor.editing_entity_anim_name = new_name
								Entity.saveAnimations(EntityClass)
								
								# cause rerender immediately so cursor doesn't get moved to the end of the field
								update()
						E "label.mdl-textfield__label", "Name..."
					E "button.mdl-button.mdl-js-button.mdl-button--icon.mdl-color-text--grey-600.delete",
						onClick: (e)=>
							e.preventDefault()
							delete_item()
							Entity.saveAnimations(EntityClass)
						E "i.material-icons", "delete"
			E EntityPreview, {
				entity, max_width, max_height
				ref: (@entity_preview)=>
			}
	
	componentDidMount: ->
		componentHandler.upgradeElement(ReactDOM.findDOMNode(@mdl_textfield_el)) if @mdl_textfield_el?

		if @name_input_el?.dataset.invalidNotUnique
			@name_input_el.setCustomValidity("Please enter a unique name.")
