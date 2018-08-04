
module.exports = (object, old_key, new_key)->
	new_object = {}
	for k, v of object
		if k is old_key
			new_object[new_key] = v
		else
			new_object[k] = v
	# return new_object
	for k, v of object
		delete object[k]
	for k, v of new_object
		object[k] = v
