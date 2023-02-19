/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */

let animate;
import {View, Mouse, Editor} from "skele2d";
import World from "./World.coffee";
import Rock from "./entities/terrain/Rock.coffee";
import Snow from "./entities/terrain/Snow.coffee";
// import keyboard from "./keyboard.coffee"

Math.seedrandom("A world");

const world = new World;

const terrain = new Snow;
world.entities.push(terrain);
terrain.x = 0;
terrain.y = 0;
terrain.generate();

const canvas = document.createElement("canvas");
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
	__guardMethod__(console, 'error', o => o.error("Failed to load save:", e));
}

try {
	if (!isNaN(localStorage.view_center_x)) { view_to.center_x = (view.center_x = parseFloat(localStorage.view_center_x)); }
	if (!isNaN(localStorage.view_center_y)) { view_to.center_y = (view.center_y = parseFloat(localStorage.view_center_y)); }
	if (!isNaN(localStorage.view_scale)) { view_to.scale = (view.scale = parseFloat(localStorage.view_scale)); }
} catch (error) {}

setInterval(function() {
	if (editor.editing) {
		// TODO: should probably only save if you pan/zoom
		localStorage.view_center_x = view.center_x;
		localStorage.view_center_y = view.center_y;
		return localStorage.view_scale = view_to.scale;
	}
}
, 200);

(animate = function() {
	if (window.CRASHED) { return; }
	requestAnimationFrame(animate);
	
	if (canvas.width !== innerWidth) { canvas.width = innerWidth; }
	if (canvas.height !== innerHeight) { canvas.height = innerHeight; }
	
	ctx.clearRect(0, 0, canvas.width, canvas.height);
	
	if (editor.editing && (editor.entities_bar.hovered_cell || ((editor.hovered_points.length || editor.hovered_entities.length) && !editor.selection_box))) {
		canvas.classList.add("grabbable");
	} else {
		canvas.classList.remove("grabbable");
	}
	
	if (!editor.editing) {
		for (var entity of Array.from(world.entities)) { // when entity isnt editor.editing_entity and entity not in editor.dragging_entities
			entity.step(world);
		}
	}
		
		// TODO: allow margin of offcenteredness
		// player = world.getEntitiesOfType(Player)[0]
		// view_to.center_x = player.x
		// view_to.center_y = player.y
	
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
	
	world.draw(ctx, view);
	if (editor.editing) { editor.draw(ctx, view); }
	
	ctx.restore();
	
	return editor.updateGUI();
})();
	
	// keyboard.resetForNextStep()

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}