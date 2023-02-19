import { Terrain, addEntityClass } from "skele2d";

export default class Rock extends Terrain {
	constructor() {
		super();
		this.bbox_padding = 20;
	}

	draw(ctx, view) {
		ctx.beginPath();
		for (var point_name in this.structure.points) {
			var point = this.structure.points[point_name];
			ctx.lineTo(point.x, point.y);
		}
		ctx.closePath();
		ctx.fillStyle = "#63625F";
		ctx.fill();
	}
};
addEntityClass(Rock);
