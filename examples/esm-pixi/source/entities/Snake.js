import { Entity, addEntityClass, helpers } from "skele2d";
const { distanceToLineSegment, closestPointOnLineSegment } = helpers;
import { Texture, groupD8, Point, SimpleRope, Container, Renderer, Ticker } from "pixi.js";

const snake_texture = Texture.from('assets/snake.png');
snake_texture.rotate = groupD8.MIRROR_HORIZONTAL;

export default class Snake extends Entity {
	constructor() {
		super();
		// relying on key order, so points & segments must not be named with simple numbers,
		// since numeric keys are sorted before other keys
		this.structure.addPoint("head");
		let previous_part_name = "head";
		for (let i = 1; i < 20; i++) {
			const part_name = `part_${i}`;
			previous_part_name = this.structure.addSegment({
				from: previous_part_name,
				to: part_name,
				name: part_name,
				length: 50,
				width: 40
			});
		}

		const parts_list = Object.values(this.structure.points).filter(part => part.name.match(/head|part/));
		for (let part_index = 0; part_index < parts_list.length; part_index++) {
			const part = parts_list[part_index];
			part.radius = 50; //- part_index*0.1
			part.vx = 0;
			part.vy = 0;
		}

		this.structure.points.head.radius *= 1.2;

		this.bbox_padding = 150;
	}

	toJSON() {
		const def = {};
		for (let k in this) {
			const v = this[k];
			if (!k.startsWith("$_")) {
				def[k] = v;
			}
		}
		return def;
	}

	initLayout() {
		for (let segment_name in this.structure.segments) {
			const segment = this.structure.segments[segment_name];
			segment.b.x = segment.a.x + segment.length;
		}
	}

	step(world) {
		let part, part_index, segment, segment_name;
		const parts_list = Object.values(this.structure.points).filter(part => part.name.match(/head|part/));

		// stop at end of the world
		for (part of parts_list) {
			if ((part.y + this.y) > 400) {
				return;
			}
		}

		// reset/init
		for (part of parts_list) {
			part.fx = 0;
			part.fy = 0;
		}

		// move
		const collision = point => world.collision(this.toWorld(point), {
			types: entity => !["Snake"].includes(entity.constructor.name)
		});
		const t = performance.now() / 1000;
		for (part_index = 0; part_index < parts_list.length; part_index++) {
			// part.x += part.vx
			// part.y += part.vy
			part = parts_list[part_index];
			const hit = collision(part);
			if (hit) {
				part.vx = 0;
				part.vy = 0;
				// Project the part's position back to the surface of the ground.
				// This is done by finding the closest point on the polygon's edges.
				let closest_distance = Infinity;
				let closest_segment = null;
				const part_world = this.toWorld(part);
				const part_in_hit_space = hit.fromWorld(part_world);
				for (segment_name in hit.structure.segments) {
					segment = hit.structure.segments[segment_name];
					const dist = distanceToLineSegment(part_in_hit_space, segment.a, segment.b);
					if ((dist < closest_distance) && (Math.hypot(segment.a.x - segment.b.x, segment.a.y - segment.b.y) > 0.1)) {
						closest_distance = dist;
						closest_segment = segment;
					}
				}
				if (closest_segment) {
					const closest_point_in_hit_space = closestPointOnLineSegment(part_in_hit_space, closest_segment.a, closest_segment.b);
					const closest_point_world = hit.toWorld(closest_point_in_hit_space);
					const closest_point_local = this.fromWorld(closest_point_world);
					part.x = closest_point_local.x;
					part.y = closest_point_local.y;
				}
			} else {
				part.vy += 0.5;
				part.vx *= 0.99;
				part.vy *= 0.99;
				// @structure.stepLayout({gravity: 0.005, collision})
				// @structure.stepLayout() for [0..10]
				// @structure.stepLayout({collision}) for [0..4]
				part.x += part.vx;
				part.y += part.vy;
			}

			// angular constraint pivoting on this part
			const relative_angle = ((Math.sin((Math.sin(t) * Math.PI) / 4) - 0.5) * Math.PI) / parts_list.length / 2;
			part.relative_angle = relative_angle;
			const prev_part = parts_list[part_index - 1];
			const next_part = parts_list[part_index + 1];
			if (prev_part && next_part) {
				this.accumulate_angular_constraint_forces(prev_part, next_part, part, relative_angle);
			}
		}

		// apply forces
		for (part of parts_list) {
			part.vx += part.fx;
			part.vy += part.fy;
			part.x += part.fx;
			part.y += part.fy;
		}

		// constrain distances
		for (let i = 0; i < 4; i++) {
			var delta_length, delta_x, delta_y, diff;
			for (segment_name in this.structure.segments) {
				segment = this.structure.segments[segment_name];
				delta_x = segment.a.x - segment.b.x;
				delta_y = segment.a.y - segment.b.y;
				delta_length = Math.sqrt((delta_x * delta_x) + (delta_y * delta_y));
				diff = (delta_length - segment.length) / delta_length;
				if (isFinite(diff)) {
					segment.a.x -= delta_x * 0.5 * diff;
					segment.a.y -= delta_y * 0.5 * diff;
					segment.b.x += delta_x * 0.5 * diff;
					segment.b.y += delta_y * 0.5 * diff;
					segment.a.vx -= delta_x * 0.5 * diff;
					segment.a.vy -= delta_y * 0.5 * diff;
					segment.b.vx += delta_x * 0.5 * diff;
					segment.b.vy += delta_y * 0.5 * diff;
				} else {
					console.warn("diff is not finite, for Snake distance constraint");
				}
			}
			// self-collision
			for (part_index = 0; part_index < parts_list.length; part_index++) {
				part = parts_list[part_index];
				for (let other_part_index = 0; other_part_index < parts_list.length; other_part_index++) { //when part_index isnt other_part_index
					const other_part = parts_list[other_part_index];
					if (Math.abs(part_index - other_part_index) < 3) {
						continue;
					}
					delta_x = part.x - other_part.x;
					delta_y = part.y - other_part.y;
					delta_length = Math.sqrt((delta_x * delta_x) + (delta_y * delta_y));
					const target_min_length = part.radius + other_part.radius;
					if (delta_length < target_min_length) {
						diff = (delta_length - target_min_length) / delta_length;
						if (isFinite(diff)) {
							part.x -= delta_x * 0.5 * diff;
							part.y -= delta_y * 0.5 * diff;
							other_part.x += delta_x * 0.5 * diff;
							other_part.y += delta_y * 0.5 * diff;
							part.vx -= delta_x * 0.5 * diff;
							part.vy -= delta_y * 0.5 * diff;
							other_part.vx += delta_x * 0.5 * diff;
							other_part.vy += delta_y * 0.5 * diff;
						} else {
							console.warn("diff is not finite, for Snake self-collision constraint");
						}
					}
				}
			}
		}

	}

	accumulate_angular_constraint_forces(a, b, pivot, relative_angle) {
		const angle_a = Math.atan2(a.y - b.y, a.x - b.x);
		const angle_b = Math.atan2(pivot.y - b.y, pivot.x - b.x);
		const angle_diff = (angle_a - angle_b) - relative_angle;

		// angle_diff *= 0.9
		const distance = Math.hypot(a.x - b.x, a.y - b.y);
		// distance_a = Math.hypot(a.x - pivot.x, a.y - pivot.y)
		// distance_b = Math.hypot(b.x - pivot.x, b.y - pivot.y)
		// angle_diff /= Math.max(1, (distance / 5) ** 2.4)

		const old_a = { x: a.x, y: a.y };
		const old_b = { x: b.x, y: b.y };

		// Rotate around pivot.
		const rot_matrix = [[Math.cos(angle_diff), Math.sin(angle_diff)], [-Math.sin(angle_diff), Math.cos(angle_diff)]];
		const rot_matrix_inverse = [[Math.cos(-angle_diff), Math.sin(-angle_diff)], [-Math.sin(-angle_diff), Math.cos(-angle_diff)]];
		for (const point of [a, b]) {
			// Translate and rotate.
			[point.x, point.y] = [point.x, point.y].map((value, index) =>
				((point === a ? rot_matrix : rot_matrix_inverse)[index][0] * (point.x - pivot.x)) +
				((point === a ? rot_matrix : rot_matrix_inverse)[index][1] * (point.y - pivot.y))
			);
			// Translate back.
			point.x += pivot.x;
			point.y += pivot.y;
		}

		const f = 0.5;
		// using individual distances can cause spinning (overall angular momentum from nothing)
		// f_a = f / Math.max(1, Math.max(0, distance_a - 3) ** 1)
		// f_b = f / Math.max(1, Math.max(0, distance_b - 3) ** 1)
		// using the combined distance conserves overall angular momentum,
		// to say nothing of the physicality of the rest of this system
		// but it's a clear difference in zero gravity
		const f_a = f / Math.max(1, Math.pow(Math.max(0, distance - 6), 1));
		const f_b = f / Math.max(1, Math.pow(Math.max(0, distance - 6), 1));

		// Turn difference in position into velocity.
		a.fx += (a.x - old_a.x) * f_a;
		a.fy += (a.y - old_a.y) * f_a;
		b.fx += (b.x - old_b.x) * f_b;
		b.fy += (b.y - old_b.y) * f_b;

		// Opposite force on pivot.
		pivot.fx -= (a.x - old_a.x) * f_a;
		pivot.fy -= (a.y - old_a.y) * f_a;
		pivot.fx -= (b.x - old_b.x) * f_b;
		pivot.fy -= (b.y - old_b.y) * f_b;

		// Restore old position.
		a.x = old_a.x;
		a.y = old_a.y;
		b.x = old_b.x;
		b.y = old_b.y;
	}

	destroy() {
		if (this.$_container) {
			this.$_container.destroy();
			this.$_container = null;
		}
		if (this.$_ticker) {
			this.$_ticker.remove(this.$_tick);
			this.$_ticker = null;
			this.$_tick = null;
		}
	}

	pixiUpdate(stage, ticker) {
		if (this.$_container) {
			return;
		}

		const rope_points = [];

		for (let point_name in this.structure.points) {
			const point = this.structure.points[point_name];
			rope_points.push(new Point(point.x, point.y));
		}

		const strip = new SimpleRope(snake_texture, rope_points);

		this.$_container = new Container();
		this.$_container.x = this.x;
		this.$_container.y = this.y;

		stage.addChild(this.$_container);

		this.$_container.addChild(strip);

		this.$_ticker = ticker;
		this.$_ticker.add(this.$_tick = () => {
			this.$_container.x = this.x;
			this.$_container.y = this.y;
			const iterable = Object.values(this.structure.points);
			for (let i = 0; i < iterable.length; i++) {
				const part = iterable[i];
				rope_points[i].x = part.x;
				rope_points[i].y = part.y;
			}
		});
	}

	draw(ctx, view, world) {
		if (view.is_preview) {
			// Skele2D isn't set up to handle PIXI rendering for preview in the entities bar.
			// Create and draw PIXI canvas to preview canvas.
			if (!this.$_preview_pixi_renderer) {
				this.$_preview_pixi_renderer = new Renderer({
					width: view.width,
					height: view.height,
					backgroundAlpha: 0,
					antialias: true,
					resolution: 1,
				});
			}
			if (!this.$_preview_pixi_stage) {
				this.$_preview_pixi_stage = new Container();
			}
			this.$_preview_pixi_stage.x = (-view.center_x * view.scale) + (view.width / 2);
			this.$_preview_pixi_stage.y = (-view.center_y * view.scale) + (view.height / 2);
			this.$_preview_pixi_stage.scale.x = view.scale;
			this.$_preview_pixi_stage.scale.y = view.scale;
			this.$_preview_pixi_ticker = new Ticker();
			this.$_preview_pixi_ticker.autoStart = false;
			this.$_preview_pixi_ticker.stop();
			this.pixiUpdate(this.$_preview_pixi_stage, this.$_preview_pixi_ticker);
			this.$_preview_pixi_renderer.render(this.$_preview_pixi_stage);
			// Undo view transform since we're handling the transform with PIXI.
			ctx.setTransform(1, 0, 0, 1, 0, 0);
			ctx.drawImage(this.$_preview_pixi_renderer.view, 0, 0);
		}
	}
};
addEntityClass(Snake);
