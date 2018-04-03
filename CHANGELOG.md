
# Changelog

The software is essentially unreleased, but I thought I might as well get in a habit of doing a changelog.

TODO: follow [some more conventions](https://keepachangelog.com/);
this will become more important when this project gets a proper release, and I'll start giving better descriptions and things as well.

Check out this fancy Unreleased section, based off of React's changelog:

## [Unreleased]
<details>
	<summary>
		Changes in master that are not yet released.
		Click to see more.
	</summary>

* The supported version of React is now v16 (updated to v16.2.0 in the demo from v15); no new APIs are used (*yet* anyway); but they could be and at that point this could come into play.

</details>

## v0.0.3

- Editor GUI fixes
	- The entities bar now correctly shows a scrollbar when there's overflow
	- Placeholders for when there are no animations/poses now consistently take up full width
- Fixed a React warning

## v0.0.2

- Updated for CoffeeScript 2 compatibility.

## v0.0.1

- Moved the required CSS into the package at `source/styles.css` (Material UI CSS and other external resources are still required).
- Removed `keyboard.coffee` from the package. It was only used by [Tiamblia][] as a helper in the game code, and not by the editor. (Kept the code in the example, unused.)
- `View` easing works differently now. Instead of `View` having `*_to` properties, it now only represents a specific viewport. You create two views, i.e. `view` and `view_to`, and call `view.easeTowards(view_to, smoothness)`
- `new Editor(world, view, canvas)` -> `new Editor(world, view, view_to, canvas)`
- `Mouse` no longer takes a `View` just to provide a silly helper function, so `new Mouse(canvas, view)` -> `new Mouse(canvas)`
- `mouse.toWorld()` is gone, so you can do `view.toWorld(mouse)` instead
- `mouse.endStep()` -> `mouse.resetForNextStep()`

## v0.0.0

- Just starting to extract this from [Tiamblia][],
published so I can start referencing this package in Tiamblia.
- Published as uncompiled CoffeeScript. So are any further versions until I mention otherwise.

[Tiamblia]: https://github.com/1j01/tiamblia-game
