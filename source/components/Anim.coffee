
# awkward component Anim represents a pose OR an animation OR an animation frame (which is an unnamed pose)

class @Anim extends React.Component
	constructor: ->
		super
	
	render: ->
		{entity, EntityClass, name, type_of_anims, selected, select, delete_item, update, editor} = @props
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
					E ".mdl-textfield.mdl-js-textfield.name",
						ref: (@mdl_textfield_el)=>
						E "input.mdl-textfield__input",
							value: name
							onChange: (e)=>
								new_name = e.target.value
								# TODO: use error classes and messages instead of instrusive alerts
								if type_of_anims is "animations"
									if EntityClass.animations[new_name]
										alert("There's already an animation with the name #{new_name}")
										return
								else if type_of_anims is "poses"
									if EntityClass.poses[new_name]
										alert("There's already a pose with the name #{new_name}")
										return
								else
									return
								
								anims_object = EntityClass[type_of_anims]
								rename_object_key(anims_object, name, new_name)
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
				entity, max_width: 200, max_height: 100
				ref: (@entity_preview)=>
			}
	
	componentDidMount: ->
		componentHandler.upgradeElement(ReactDOM.findDOMNode(@mdl_textfield_el)) if @mdl_textfield_el?
