import Entity from "./base-entities/Entity.coffee"
import Terrain from "./base-entities/Terrain.coffee"
import Structure from "./structure/Structure.coffee"

import BoneStructure from "./structure/BoneStructure.coffee"
import PolygonStructure from "./structure/BoneStructure.coffee"
import Pose from "./structure/Pose.coffee"

import Editor from "./Editor.coffee"
import View from "./View.coffee"
import Mouse from "./Mouse.coffee"

import {entityClasses, addEntityClass} from "./entity-class-registry.coffee"

import * as helpers from "./helpers.coffee"

# TODO: ES module export version of the library?
# i.e. export { ... }

export default ({
	Entity
	Terrain
	Structure

	BoneStructure
	PolygonStructure
	Pose

	Editor
	View
	Mouse

	entityClasses
	addEntityClass

	helpers
})
