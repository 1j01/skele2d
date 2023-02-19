/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import {Terrain, Entity} from "skele2d";

export default class World {
	constructor() {
		this.entities = [];
	}
	
	fromJSON(def){
		if (!(def.entities instanceof Array)) {
			throw new Error(`Expected entities to be an array, got ${def.entities}`);
		}
		this.entities = (Array.from(def.entities).map((ent_def) => Entity.fromJSON(ent_def)));
		return Array.from(this.entities).map((entity) =>
			entity.resolveReferences(this));
	}
	
	getEntityByID(id){
		for (var entity of Array.from(this.entities)) {
			if (entity.id === id) { return entity; }
		}
	}
	
	getEntitiesOfType(Class){
		return Array.from(this.entities).filter((entity) => entity instanceof Class);
	}
	
	drawBackground(ctx, view){
		ctx.fillStyle = "#32C8FF";
		return ctx.fillRect(0, 0, view.width, view.height);
	}
	
	draw(ctx, view){
		// ctx.fillStyle = "#32C8FF"
		// {x, y} = view.toWorld({x: 0, y: 0})
		// {x: width, y: height} = view.toWorld({x: view.width, y: view.height})
		// ctx.fillRect(x, y, width-x, height-y)
		return (() => {
			const result = [];
			for (var entity of Array.from(this.entities)) {
				ctx.save();
				ctx.translate(entity.x, entity.y);
				entity.draw(ctx, view);
				result.push(ctx.restore());
			}
			return result;
		})();
	}
	
	collision(point){
		for (var entity of Array.from(this.entities)) {
			if (entity instanceof Terrain) {
				if (entity.structure.pointInPolygon(entity.fromWorld(point))) {
					return true;
				}
			}
		}
		return false;
	}
}
