
class @AnimGroup extends React.Component
	render: ->
		{entity, EntityClass, array_to_push_anims_to, update, type_of_anims} = @props
		E ".anim-group",
			if EntityClass?
				if type_of_anims is "poses"
					if EntityClass.poses?
						if Object.keys(EntityClass.poses).length > 0
							i = 0
							for pose_name, pose of EntityClass.poses then do (pose_name, pose)=>
								i += 1
								selected = editor.editing_entity_anim_name is pose_name and not editor.editing_entity_animation_frame_index?
								E Anim, {
									key: i
									name: pose_name
									entity, EntityClass, selected, editor, update, type_of_anims
									# pose
									select: =>
										editor.editing_entity_anim_name = pose_name
										editor.editing_entity_animation_frame_index = null
										unless pose_name is "Current Pose"
											entity.structure.setPose(EntityClass.poses[pose_name])
									delete_item: =>
										delete EntityClass.poses[pose_name]
										editor.editing_entity_anim_name = "Current Pose"
										editor.editing_entity_animation_frame_index = null
									get_pose: =>
										if pose_name is "Current Pose" or selected
											entity.structure.getPose()
										else
											EntityClass.poses[pose_name]
									ref: (anim)=>
										array_to_push_anims_to.push(anim) if anim?
								}
						else
							E "article.placeholder", "No poses"
					else
						E "article.placeholder", "Entity class is not initialized for animation"
				else if type_of_anims is "animations"
					if EntityClass.animations?
						if Object.keys(EntityClass.animations).length > 0
							i = 0
							for animation_name, animation of EntityClass.animations then do (animation_name, animation)=>
								i += 1
								selected = editor.editing_entity_anim_name is animation_name and editor.editing_entity_animation_frame_index?
								E Anim, {
									key: i
									name: animation_name
									entity, EntityClass, selected, editor, update, type_of_anims
									# animation
									# TODO: bounds of anim should be determined across all frames
									select: =>
										editor.editing_entity_anim_name = animation_name
										editor.editing_entity_animation_frame_index = 0
										pose = EntityClass.animations[animation_name]?[0]
										entity.structure.setPose(pose) if pose
									delete_item: =>
										delete EntityClass.animations[animation_name]
										editor.editing_entity_anim_name = "Current Pose"
										editor.editing_entity_animation_frame_index = null
									get_pose: =>
										# TODO: animate only if anim is the hovered||selected one
										animation = EntityClass.animations[animation_name]
										return unless animation # TODO: shouldn't need this or other ?s
										Pose.lerpAnimationLoop(animation, EntityClass.animations[animation_name].length * Date.now()/1000/2)
									ref: (anim)=>
										array_to_push_anims_to.push(anim) if anim?
								}
						else
							E "article.placeholder", "No animations"
					else
						E "article.placeholder", "Entity class is not initialized for animation"
				else if type_of_anims is "animation-frames"
					if EntityClass.animations?
						animation_name = editor.editing_entity_anim_name
						frames = EntityClass.animations[animation_name]
						if frames?
							for frame, frame_index in frames then do (frame, frame_index)=>
								selected = editor.editing_entity_anim_name is animation_name and editor.editing_entity_animation_frame_index is frame_index
								E Anim, {
									key: frame_index
									name: "Frame #{frame_index}"
									entity, EntityClass, selected, editor, update, type_of_anims
									# animation frame
									select: =>
										editor.editing_entity_anim_name = animation_name
										editor.editing_entity_animation_frame_index = frame_index
										pose = EntityClass.animations[animation_name][frame_index]
										entity.structure.setPose(pose)
									delete_item: =>
										EntityClass.animations[animation_name].splice(frame_index, 1)
									get_pose: =>
										if selected
											entity.structure.getPose()
										else
											animation = EntityClass.animations[animation_name]
											animation?[frame_index]
									ref: (anim)=>
										array_to_push_anims_to.push(anim) if anim?
								}
						else
							E "article.placeholder", "Error: Trying to display the frames of a non-existant animation"
					else
						E "article.placeholder", "Error: Entity class is not initialized for animation, trying to display the frames of an animation?"
				else
					E "article.placeholder", "Error: weird type_of_anims for AnimGroup #{type_of_anims}"
			E "button.add-anim-fab.mdl-button.mdl-js-button.mdl-button--fab.mdl-js-ripple-effect.mdl-button--colored",
				ref: (@new_anim_button)=>
				onClick: =>
					if type_of_anims is "animation-frames"
						animation = EntityClass.animations[editor.editing_entity_anim_name]
						new_pose = entity.structure.getPose()
						animation.push(new_pose)
						editor.editing_entity_animation_frame_index = animation.length - 1
					else
						default_name = switch type_of_anims
							when "poses" then "New Pose"
							when "animations" then "New Animation"
						new_name = default_name
						i = 1
						while EntityClass[type_of_anims][new_name]?
							new_name = "#{default_name} #{i}"
							i += 1
						
						switch type_of_anims
							when "poses"
								EntityClass.poses[new_name] = entity.structure.getPose()
								editor.editing_entity_animation_frame_index = null
							when "animations"
								EntityClass.animations[new_name] = [entity.structure.getPose()]
								editor.editing_entity_animation_frame_index = 0
						
						editor.editing_entity_anim_name = new_name
					
					Entity.saveAnimations(EntityClass)
					
					update()
				
				E "i.material-icons", "add"
	
	componentDidMount: =>
		componentHandler.upgradeElement(ReactDOM.findDOMNode(@new_anim_button))
	# XXX: have to upgrade when the bar becomes visible
	componentDidUpdate: =>
		componentHandler.upgradeElement(ReactDOM.findDOMNode(@new_anim_button))
