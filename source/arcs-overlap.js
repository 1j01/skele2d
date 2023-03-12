const TAU = Math.PI * 2;

export function arcsOverlap(startAngle1, angleDiff1, startAngle2, angleDiff2) {

	// Handle full circles
	if (Math.abs(angleDiff1) >= TAU || Math.abs(angleDiff2) >= TAU) {
		return true;
	}

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
			if (startAngle1 <= startAngle2 + TAU * i && startAngle2 + TAU * i <= endAngle1) {
				return true;
			}
			if (startAngle2 <= startAngle1 + TAU * i && startAngle1 + TAU * i <= endAngle2) {
				return true;
			}
			if (startAngle1 <= endAngle2 + TAU * i && endAngle2 + TAU * i <= endAngle1) {
				return true;
			}
			if (startAngle2 <= endAngle1 + TAU * i && endAngle1 + TAU * i <= endAngle2) {
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
			if (startAngle1 <= startAngle2 + TAU * i && startAngle2 + TAU * i <= endAngle1) {
				return true;
			}
			if (startAngle2 <= startAngle1 + TAU * i && startAngle1 + TAU * i <= endAngle2) {
				return true;
			}
			if (startAngle1 <= endAngle2 + TAU * i && endAngle2 + TAU * i <= endAngle1) {
				return true;
			}
			if (startAngle2 <= endAngle1 + TAU * i && endAngle1 + TAU * i <= endAngle2) {
				return true;
			}
		}
	}

	return false;
}

export function visualizeAngles(startAngle1, angleDiff1, startAngle2, angleDiff2) {
	const canvas = document.createElement("canvas");
	document.body.append(canvas);
	canvas.width = canvas.height = 100;
	const ctx = canvas.getContext("2d");
	ctx.save();
	ctx.translate(canvas.width / 2, canvas.height / 2);
	// ctx.rotate(Math.PI / 2); // or something?
	const r = canvas.width / 2 * 0.9;
	ctx.beginPath();
	ctx.arc(0, 0, r, 0, Math.PI * 2);
	ctx.stroke();

	function drawArc(startAngle, angleDiff, radius, thickness, color) {
		ctx.lineWidth = thickness;
		ctx.strokeStyle = color;
		ctx.beginPath();
		ctx.arc(0, 0, radius, startAngle, startAngle + angleDiff, angleDiff < 0);
		ctx.stroke();
	}
	drawArc(startAngle1, angleDiff1, r / 2, r / 2, "rgba(255, 0, 0, 0.7)");
	drawArc(startAngle2, angleDiff2, r / 2 + 4, r / 2, "rgba(0, 0, 255, 0.5)");

	ctx.restore();

	const url = canvas.toDataURL();
	const css = `
		font-size: 1px;
		padding:
			${Math.floor(canvas.height / 2)}px
			${Math.floor(canvas.width / 2)}px;
		line-height: ${canvas.height}px;
		background-image: url('${url}');
		background-size: ${canvas.width}px ${canvas.height}px;
		background-position: center center;
		background-repeat: no-repeat;
		color: transparent;
	`;
	console.log("%c.", css);
}
