
class @AnimBar extends React.Component
	constructor: ->
		super
		@state = {visible: no}
	
	render: ->
		{editor} = @props
		{visible, EntityClass} = @state
		
		entity = editor.editing_entity ? @shown_entity
		editing_an_animation = editor.editing_entity_animation_frame_index?
		@shown_entity = entity
		
		@anims = []
		# TODO: remove references from @anims on Anim::componentWillUnmount
		E ".bar.sidebar.anim-bar", class: {visible},
			E ".anims",
				E "h1", "Poses"
				E AnimGroup, {entity, EntityClass, array_to_push_anims_to: @anims, update: @update, type_of_anims: "poses"}
				E "h1", "Animations"
				E AnimGroup, {entity, EntityClass, array_to_push_anims_to: @anims, update: @update, type_of_anims: "animations"}
			E ".animation-frames", class: {visible: visible and editing_an_animation},
				E "h1", "Frames"
				E AnimGroup, {entity, EntityClass, array_to_push_anims_to: @anims, update: @update, type_of_anims: "animation-frames", editing_frame_index: editor.editing_entity_animation_frame_index}
	
	update: (show)=>
		{editor} = @props
		{editing_entity_anim_name, editing_entity} = editor
		
		EntityClass = if editing_entity? then entity_classes[editing_entity._class_]
		show = show and EntityClass?.animations
		if show
			for anim in @anims
				pose = anim.props.get_pose()
				if pose?
					anim.entity_preview.entity.structure.setPose(pose)
					anim.entity_preview.update()
		
		@setState {visible: show, EntityClass, editing_entity_anim_name}

