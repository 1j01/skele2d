
# TODO: replace this with just passing a list of entities to the Editor (and stuff), probably

exports.entityClasses = {}
exports.addEntityClass = (constructor)->
	exports.entityClasses[constructor.name] = constructor
