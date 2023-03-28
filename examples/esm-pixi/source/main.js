import { View, Mouse, Editor } from "skele2d";
import { Application as PIXI_Application } from "pixi.js";
import World from "./World.js";
import Rock from "./entities/terrain/Rock.js";
import Snow from "./entities/terrain/Snow.js";
import Snake from "./entities/Snake.js";
// import keyboard from "./keyboard.js";

Math.seedrandom("A world");

const world = new World;

const terrain = new Snow;
world.entities.push(terrain);
terrain.x = 0;
terrain.y = 0;
terrain.generate();

const snake = new Snake;
world.entities.push(snake);

const app = new PIXI_Application({ resizeTo: window });
document.body.appendChild(app.view);
app.view.style.position = "absolute";
app.view.style.top = "0";
app.view.style.left = "0";
// for PixiJS Devtools
globalThis.__PIXI_APP__ = app;

const canvas = document.createElement("canvas");
canvas.style.position = "absolute";
canvas.style.top = "0";
canvas.style.left = "0";
document.body.appendChild(canvas);
const ctx = canvas.getContext("2d");

const view = new View;
const view_to = new View;
const view_smoothness = 7;
const mouse = new Mouse(canvas);

const editor = new Editor(world, view, view_to, canvas, mouse);
try {
	editor.load();
} catch (e) {
	console.error?.("Failed to load save:", e);
}

try {
	if (!isNaN(localStorage.view_center_x)) { view_to.center_x = (view.center_x = parseFloat(localStorage.view_center_x)); }
	if (!isNaN(localStorage.view_center_y)) { view_to.center_y = (view.center_y = parseFloat(localStorage.view_center_y)); }
	if (!isNaN(localStorage.view_scale)) { view_to.scale = (view.scale = parseFloat(localStorage.view_scale)); }
} catch (error) { }

setInterval(function () {
	if (editor.editing) {
		// TODO: should probably only save if you pan/zoom
		localStorage.view_center_x = view.center_x;
		localStorage.view_center_y = view.center_y;
		localStorage.view_scale = view_to.scale;
	}
}, 200);

let old_entities_list = [];

app.ticker.add(function () {
	if (window.CRASHED) { return; }

	if (canvas.width !== innerWidth) { canvas.width = innerWidth; }
	if (canvas.height !== innerHeight) { canvas.height = innerHeight; }

	ctx.clearRect(0, 0, canvas.width, canvas.height);

	if (editor.editing && (editor.entities_bar.hovered_cell || ((editor.hovered_points.length || editor.hovered_entities.length) && !editor.selection_box))) {
		canvas.classList.add("grabbable");
	} else {
		canvas.classList.remove("grabbable");
	}

	if (!editor.editing) {
		for (var entity of world.entities) { // if (entity !== editor.editing_entity && !editor.dragging_entities.contains(entity)) {
			entity.step(world);
		}

		// TODO: allow margin of offcenteredness
		// player = world.getEntitiesOfType(Player)[0];
		// view_to.center_x = player.x;
		// view_to.center_y = player.y;
	}

	view.width = canvas.width;
	view.height = canvas.height;

	view.easeTowards(view_to, view_smoothness);
	if (editor.editing) { editor.step(); }
	mouse.resetForNextStep();

	world.drawBackground(ctx, view);
	ctx.save();
	ctx.translate(canvas.width / 2, canvas.height / 2);
	ctx.scale(view.scale, view.scale);
	ctx.translate(-view.center_x, -view.center_y);

	// align PIXI scene to the CanvasRenderingContext2D scene
	app.stage.position.x = -view.center_x * view.scale + canvas.width / 2;
	app.stage.position.y = -view.center_y * view.scale + canvas.height / 2;
	app.stage.scale.x = view.scale;
	app.stage.scale.y = view.scale;

	// Note: this doesn't cause PIXI to actually redraw.
	world.pixiUpdate(app.stage, app.ticker);

	world.draw(ctx, view);
	if (editor.editing) { editor.draw(ctx, view); }

	ctx.restore();

	editor.updateGUI();

	// keyboard.resetForNextStep();

});
