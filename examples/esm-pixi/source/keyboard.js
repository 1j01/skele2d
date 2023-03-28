const specialKeys = {
	backspace: 8, tab: 9, clear: 12,
	enter: 13, return: 13,
	esc: 27, escape: 27, space: 32,
	left: 37, up: 38,
	right: 39, down: 40,
	del: 46, delete: 46,
	home: 36, end: 35,
	pageup: 33, pagedown: 34,
	',': 188, '.': 190, '/': 191,
	'`': 192, '-': 189, '=': 187,
	';': 186, '\'': 222,
	'[': 219, ']': 221, '\\': 220
};

const keyCodeFor = function (keyName) {
	return specialKeys[keyName.toLowerCase()] ?? keyName.toUpperCase().charCodeAt(0);
};

const keys = {};
let prev_keys = {};
addEventListener("keydown", e => keys[e.keyCode] = true);
addEventListener("keyup", e => delete keys[e.keyCode]);

const keyboard = {
	wasJustPressed(keyName) {
		return keys[keyCodeFor(keyName)] && !prev_keys[keyCodeFor(keyName)];
	},
	isHeld(keyName) {
		return keys[keyCodeFor(keyName)];
	},
	resetForNextStep() {
		prev_keys = {};
		for (var k in keys) {
			var v = keys[k];
			prev_keys[k] = v;
		}
	}
};

export default keyboard;
