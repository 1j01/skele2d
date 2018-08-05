
# TODO: replace this with just passing a list of entities to the Editor (and stuff), probably

export entityClasses = {}
export addEntityClass = (constructor)->
	entityClasses[constructor.name] = constructor
