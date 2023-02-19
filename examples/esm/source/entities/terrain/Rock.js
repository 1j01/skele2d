/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let Rock;
import {Terrain, addEntityClass} from "skele2d";

export default Rock = (function() {
	Rock = class Rock extends Terrain {
		static initClass() {
			addEntityClass(this);
		}
		constructor() {
			super();
			this.bbox_padding = 20;
		}
	
		draw(ctx, view){
			ctx.beginPath();
			for (var point_name in this.structure.points) {
				var point = this.structure.points[point_name];
				ctx.lineTo(point.x, point.y);
			}
			ctx.closePath();
			ctx.fillStyle = "#63625F";
			return ctx.fill();
		}
	};
	Rock.initClass();
	return Rock;
})();
