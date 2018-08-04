exports.Entity = require "./base-entities/Entity.coffee"
exports.Terrain = require "./base-entities/Terrain.coffee"
exports.Structure = require "./structure/Structure.coffee"

exports.BoneStructure = require "./structure/BoneStructure.coffee"
exports.PolygonStructure = require "./structure/BoneStructure.coffee"
exports.Pose = require "./structure/Pose.coffee"

exports.Editor = require "./Editor.coffee"
exports.View = require "./View.coffee"
exports.Mouse = require "./Mouse.coffee"

exports.helpers = require "./helpers.coffee"

{entityClasses, addEntityClass} = require "./entity-class-registry.coffee"
exports.entityClasses = entityClasses
exports.addEntityClass = addEntityClass
