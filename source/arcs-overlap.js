const TAU = Math.PI * 2;
const EPSILON = 0.0001;

export function arcsOverlap(startAngle1, angleDiff1, startAngle2, angleDiff2, chordMode = false) {

	// Handle zero-length arcs
	// This is before full circle handling in order to match
	// the test harness's notion of overlap which is based
	// on image comparison. If any of the arcs are zero-length,
	// no visual overlap is possible.
	// if (angleDiff1 === 0 || angleDiff2 === 0) {
	if (Math.abs(angleDiff1) < EPSILON || Math.abs(angleDiff2) < EPSILON) {
		// return startAngle1 === startAngle2;
		// return Math.abs(startAngle1 - startAngle2) < EPSILON;
		return false;
	}

	// Handle full circles
	// (This should be before floating point angle difference shrinking)
	if (Math.abs(angleDiff1) >= TAU || Math.abs(angleDiff2) >= TAU) {
		return true;
	}

	// For floating point imprecision, shrink arc lengths slightly
	angleDiff1 -= Math.sign(angleDiff1) * EPSILON;
	angleDiff2 -= Math.sign(angleDiff2) * EPSILON;

	// Simplify: only the difference in start angles matters,
	// not their absolute angles
	// This gives me confidence that I don't need to test
	// varying both parameters.
	startAngle2 -= startAngle1;
	startAngle1 = 0;

	// Normalize: wrap all angles to [0, 2π)
	startAngle1 = (startAngle1 % TAU + TAU) % TAU;
	startAngle2 = (startAngle2 % TAU + TAU) % TAU;

	// Normalize: make sure angleDiff1 is positive
	if (angleDiff1 < 0) {
		angleDiff1 *= -1;
		startAngle1 *= -1;
		angleDiff2 *= -1;
		startAngle2 *= -1;
	}

	{
		// Calculate the end angles of each arc
		const endAngle1 = startAngle1 + angleDiff1;
		const endAngle2 = startAngle2 + angleDiff2;

		for (let i = 0; i < 2; i++) {
			if (startAngle1 < startAngle2 + TAU * i && startAngle2 + TAU * i < endAngle1) {
				return true;
			}
			if (startAngle2 < startAngle1 + TAU * i && startAngle1 + TAU * i < endAngle2) {
				return true;
			}
			if (startAngle1 < endAngle2 + TAU * i && endAngle2 + TAU * i < endAngle1) {
				return true;
			}
			if (startAngle2 < endAngle1 + TAU * i && endAngle1 + TAU * i < endAngle2) {
				return true;
			}
		}
	}

	// Normalize: make sure angleDiff2 is positive
	if (angleDiff2 < 0) {
		angleDiff1 *= -1;
		startAngle1 *= -1;
		angleDiff2 *= -1;
		startAngle2 *= -1;
	}

	{
		// Calculate the end angles of each arc
		const endAngle1 = startAngle1 + angleDiff1;
		const endAngle2 = startAngle2 + angleDiff2;

		for (let i = 0; i < 2; i++) {
			if (startAngle1 < startAngle2 + TAU * i && startAngle2 + TAU * i < endAngle1) {
				return true;
			}
			if (startAngle2 < startAngle1 + TAU * i && startAngle1 + TAU * i < endAngle2) {
				return true;
			}
			if (startAngle1 < endAngle2 + TAU * i && endAngle2 + TAU * i < endAngle1) {
				return true;
			}
			if (startAngle2 < endAngle1 + TAU * i && endAngle1 + TAU * i < endAngle2) {
				return true;
			}
		}
	}

	if (chordMode) {
		const endAngle1 = startAngle1 + angleDiff1;
		const endAngle2 = startAngle2 + angleDiff2;

		// Calculate the start and end points of each chord
		const startPoint1 = { x: Math.cos(startAngle1), y: Math.sin(startAngle1) };
		const endPoint1 = { x: Math.cos(endAngle1), y: Math.sin(endAngle1) };
		const startPoint2 = { x: Math.cos(startAngle2), y: Math.sin(startAngle2) };
		const endPoint2 = { x: Math.cos(endAngle2), y: Math.sin(endAngle2) };

		const lineSegmentsIntersect = (x1, y1, x2, y2, x3, y3, x4, y4) => {
			const a_dx = x2 - x1;
			const a_dy = y2 - y1;
			const b_dx = x4 - x3;
			const b_dy = y4 - y3;
			const s = (-a_dy * (x1 - x3) + a_dx * (y1 - y3)) / (-b_dx * a_dy + a_dx * b_dy);
			const t = (+b_dx * (y1 - y3) - b_dy * (x1 - x3)) / (-b_dx * a_dy + a_dx * b_dy);
			return s >= 0 && s <= 1 && t >= 0 && t <= 1;
		};

		// Check if the chords intersect
		return lineSegmentsIntersect(
			startPoint1.x, startPoint1.y, endPoint1.x, endPoint1.y,
			startPoint2.x, startPoint2.y, endPoint2.x, endPoint2.y
		);
	}

	return false;
}
