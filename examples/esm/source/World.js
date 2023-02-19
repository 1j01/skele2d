import { Terrain, Entity } from "skele2d";

export default class World {
	constructor() {
		this.entities = [];
	}

	fromJSON(def) {
		if (!(def.entities instanceof Array)) {
			throw new Error(`Expected entities to be an array, got ${def.entities}`);
		}
		this.entities = def.entities.map((ent_def) => Entity.fromJSON(ent_def));
		for (const entity of this.entities) {
			entity.resolveReferences(this);
		}
	}

	getEntityByID(id) {
		for (var entity of this.entities) {
			if (entity.id === id) { return entity; }
		}
	}

	getEntitiesOfType(Class) {
		return this.entities.filter((entity) => entity instanceof Class);
	}

	drawBackground(ctx, view) {
		ctx.fillStyle = "#32C8FF";
		ctx.fillRect(0, 0, view.width, view.height);
	}

	draw(ctx, view) {
		// ctx.fillStyle = "#32C8FF"
		// {x, y} = view.toWorld({x: 0, y: 0})
		// {x: width, y: height} = view.toWorld({x: view.width, y: view.height})
		// ctx.fillRect(x, y, width-x, height-y)
		for (var entity of this.entities) {
			ctx.save();
			ctx.translate(entity.x, entity.y);
			entity.draw(ctx, view);
			ctx.restore();
		}
	}

	collision(point) {
		for (var entity of this.entities) {
			if (entity instanceof Terrain) {
				if (entity.structure.pointInPolygon(entity.fromWorld(point))) {
					return true;
				}
			}
		}
		return false;
	}
}
