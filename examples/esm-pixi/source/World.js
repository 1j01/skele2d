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
		// ctx.fillStyle = "#32C8FF";
		// ctx.fillRect(0, 0, view.width, view.height);
	}

	pixiUpdate(stage, ticker) {
		for (const entity of this.entities) {
			entity.pixiUpdate?.(stage, ticker);
		}
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

	collision(point, ...rest){
		// lineThickness doesn't apply to polygons like Terrain
		// also it's kind of a hack, because different entities could need different lineThicknesses
		// and different segments within an entity too
	
		let filter;
		const val = rest[0], obj = val != null ? val : {}, val1 = obj.types, types = val1 != null ? val1 : [Terrain], val2 = obj.lineThickness, lineThickness = val2 != null ? val2 : 5;
		if (typeof types === "function") {
			filter = types;
		} else {
			filter = entity=> types.some(type=> (entity instanceof type) && (entity.solid != null ? entity.solid : true));
		}
	
		for (let entity of Array.from(this.entities)) {
			if (filter(entity)) {
				const local_point = entity.fromWorld(point);
				if (entity.structure.pointInPolygon != null) {
					if (entity.structure.pointInPolygon(local_point)) {
						return entity;
					}
				} else {
					for (let segment_name in entity.structure.segments) {
						const segment = entity.structure.segments[segment_name];
						const dist = distanceToLineSegment(local_point, segment.a, segment.b);
						if (dist < lineThickness) {
							return entity;
						}
					}
				}
			}
		}
		return null;
	}
}
