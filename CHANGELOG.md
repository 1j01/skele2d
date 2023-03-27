
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
<details>
	<summary>
		Changes in master that are not yet released.
		Click to see more.
	</summary>

### Editor

- The editor now only uses custom SVG icons. You may remove Material Icons from your project if you're including it. (The previous release incorrectly stated that the editor never used Material Icons.)
- Icons are now pixel-aligned, so they shouldn't look blurry at 1x scale on low-DPI screens... except for one icon, which is impossible to align without making it off-center, or changing the line thickness, or changing all the icon sizes to an odd width. I have some alternate versions of that icon already, but I'll leave it for now.
- When naming animations or poses, it will now gracefully handle the case where the name is already taken, marking the input field as invalid, with a tooltip, and saving under a temporary name behind the scenes. Before it showed an alert, completely interrupting your typing, and you had to plan around it. For example if you were creating a second idle animation "Idle 2", it would trigger once you typed "Idle", and reject the input, and you'd have to type "Idl 2" and then go back and type the "e", or otherwise work around it.
- It no longer loads a font called Arimo from Google Fonts just for a fallback font for context menus (a weird decision in jsMenus library)
- Fixed a bug where if you right clicked an open context menu, the old context menu would stay open, unable to be closed.
- `localStorage["Skele2D show names"]` flag now supports `"hovered-or-selected"` as an option, which shows the name labels also for hovered or selected entities, rather than just the entity being edited.
- You can now set `localStorage["Skele2D allow posing animatable entities in world"] = "true"` to override the "No pose is selected. Select a pose to edit." error message, which is intended to avoid confusion since edits will not affect the animation data, and will generally have little affect once the game starts running, since the animation code will override the pose, perhaps with linear interpolation. Occasionally it's useful to just pose the entity ad-hoc, such as to test the entity's rendering in various scenarios without creating a pose for each one.

</details>

## [0.0.10] - 2023-03-14 (π day)

### Library

- `PolygonStructure` now has `bbox_min` and `bbox_max` properties, which are the minimum and maximum coordinates of the bounding box of the polygon.
  - `pointInPolygon` is now optimized to use these properties to return `false` early.
  - These properties are updated before `onchange` is called, so they can be used in `onchange`.
- There is a new `signalChange` method on `PolygonStructure`, which should be used instead of calling `onchange` (if `onchange` is set), since it also updates the bounding box properties, and may in the future support multiple listeners.
- `Terrain` no longer requires a global `SimplexNoise`; it will generate flat terrain if it's not available.
- Added helper function `closestPointOnLineSegment(point, a, b)`
- Removed icon font from demos. ~~It was never used, and the editor now sports custom SVG icons, so I have no plans to use Material Icons. You can remove it from your project if you're including it.~~ This was incorrect, the font is used for the animation bar, for add and delete buttons. Seeing as it's an external dependency, this doesn't break the release.

### Editor

- Added "Select Same Type" to the context menu for entities. You can also select multiple entities and then right-click to select all entities any of the selected entity types.
- It will no longer create useless undo states if you hit <kbd>Delete</kbd> when nothing is selected.
- Errors in entity construction, serialization, or rendering are now handled gracefully in the entities palette. The error message is shown in the palette, with hover text for the full error message. The errors are localized to the specific entity preview, instead of cascading to the whole palette.
- The "Sculpt mode" toggle is replaced with a tools bar with several tools.
  - Sculpting now works on bone structures in addition to terrain.
  - There are new Roughen and Smooth tools, which are useful for terrain, but also apply to bone structures
  - There is a new Paint tool for terrain, which lets you shape the terrain with a brush, creating and removing points as you go.
    - You can add by clicking and dragging from within the polygon, and subtract by dragging from outside the polygon.
    - This tool uses a completely bespoke algorithm for polygon merging, which handles most edge cases, but you have to be careful not to create self-intersecting polygons, as it has no way to create "islands" or "holes" in the polygon, and it will currently *expand from both sides*, rather than meeting in the middle or expanding from one side, leading to more and more self-intersecting geometry. It will also occasionally choose the wrong arc, subtracting instead of adding or visa versa. (I have fixes in progress for both of these issues.)
- You can now enable labeling points with their names or indices via the console with `localStorage["Skele2D show names"] = true` or `localStorage["Skele2D show indices"] = true`.
- Dragging entities will no longer modify `entity.vx` and `entity.vy` to "throw" entities, behavior intended for editing while simulating, which is not currently... encouraged, in any of the demos. This behavior was confusing me when I was seeing the facing direction of a player entity sometimes change when starting the simulation, even for new entities, but not always. It took me a while to figure out it was due to `vx` changing when dragging the entity into the scene. Anyways the flinging behavior wasn't that good anyways, since it didn't average the mouse movement over a time period[.](https://github.com/1j01/mind-map/blob/857d8ed54f745cb0628378861df63f6ad9d02b1b/app.coffee#LL217C33-L217C33)

## [0.0.9]

- The library is now published as ESM and UMD, both minified and unminified.
- `skele2d.js`, the `main` package export, is no longer minified.
- `skele2d.esm.js` is added as the `module` package export.
- There is a new ESM example, using vanilla JS.

## [0.0.8]

### Library
- Added [MIT license](LICENSE.txt).
- Upgraded to Webpack 5, and React 17. This took a lot of work.
- The library is now published as UMD, so it can be used as a script tag, in which case it creates a global `skele2d`. When used with Webpack, it should continue to operate as before, since UMD is compatible with CommonJS.
  - There is a new Script Tag example, which loads the UMD bundle as a script.
  - The examples are now in `examples/` and the old example is named `examples/webpack-coffee/`.
- Minification now uses Terser instead of UglifyJS.
- No longer publishing unnecessary files to npm. `.npmignore` is a bug. `files` is the only way to get it right.
- `PolygonStructure`'s `onchange` is now called only once during deserialization, rather than once for each point.

### Editor
- If deserializing the autosave fails, it will now try to load the default world, and show a warning.
- If loading the default world fails, it will now show a warning.
- If you try to paste when the clipboard is empty, it will now show a warning.
- It's now easier to undo changes that occur during simulation. Every time you hit play, an undo state is created. You can now easily restore the state prior to entering play mode.
  - Note: If there are any redos when you enter play mode, they are now discarded, as they are if you edit anything. (Non-linear history would be nice...)
- Improved handling for deleting points. I already had this feature where if you try to delete a point that an entity needs to render, it will be detected and reverted with a warning message. The problem was, if you hit *redo*, it would try to *redo the deletion*, and it would cause errors and the editor would become useless. Now the stack of redos is restored, so as far as the editing paradigm goes, you haven't made a change because it wasn't allowed. It should be seamless.
  - It will no longer save with the points deleted until it's verified that no errors occur. It was already normally saving *over* this unwanted invalid save when rolling back the state after catching an error, but if you paused in the debugger on the error and then refreshed the page without first resuming execution, it could lead to a persistently corrupted world, since it wouldn't get to do this second save. (It shouldn't have been saving twice for one operation anyways, it was sort of hidden/implicit in the code.)
- Also for deleting points, in the case that there's *no error*, previously it assumed entities won't mutate other entities during `step`, but now it restores the whole world state after `step`. (It already restored the world state in the case of an error.)

## [0.0.7]

- Minification is enabled
- Internally, switched to ES module syntax
- Changes to webpack configuration may fix `Uncaught TypeError: Class extends value undefined is not a constructor or null`

## [0.0.6] [BROKEN]

- CoffeeScript source files are no longer published
- The module is now published as a compiled bundle, and so you no longer need a complex Webpack setup to use it
- Classes are exported from `require("skele2d")` (`Entity`, `Terrain`, `Mouse`, etc.)
- Helpers are exported at `require("skele2d").helpers`
- `addEntityClass` is moved out of helpers, so it's at `require("skele2d").addEntityClass`
- `entity_classes` is moved out of helpers and renamed, so it's at `require("skele2d").entityClasses`
- `rename_object_key` is removed as it was only intended for internal use by the editor

## [0.0.5]

- Context menus are now supported in browser, not just in NW.js
    - (NW.js retains *native* context menus)
- Sculpt mode is more useful
    - Correctly saves after each gesture
    - Pushes points in the direction you move the mouse, rather than just away from the mouse, which was a temporary (and rather unpleasant and useless) implementation

## [0.0.4]

- No more global variables
    - (There's still a global store of entity classes added with `addEntityClass`, not stored on a class or anything)
- You basically have to use Webpack (or similar) now
    - Remove all Skele2D scripts, React, CoffeeScript
    - Add `<script src="build/bundle.js">`
    - Copy Webpack configuration `webpack.config.js`
    - Install modules `npm i --save-dev webpack webpack-cli webpack-dev-server coffee-loader coffeescript@2.2.3 style-loader css-loader null-loader noop-loader`
    - (CSS is included via `style-loader` (except for Material Design))
    - Add `require`s for things
        - `require` all your entities so they can be added with `addEntityClass` (this might as well be a list at this point)
        - `require("skele2d/source/base-entities/Entity.coffee")` etc.
        - So many things
- You need to pass `mouse` as an additional argument to the `Editor` constructor
- The supported version of React is now v16 (updated to v16.2.0 in the demo from v15); no new APIs are used (*yet* anyway)

## [0.0.3]

- Editor GUI fixes
	- The entities bar now correctly shows a scrollbar when there's overflow
	- Placeholders for when there are no animations/poses now consistently take up full width
- Fixed a React warning

## [0.0.2]

- Updated for CoffeeScript 2 compatibility.

## [0.0.1]

- Moved the required CSS into the package at `source/styles.css` (Material UI CSS and other external resources are still required).
- Removed `keyboard.coffee` from the package. It was only used by [Tiamblia][] as a helper in the game code, and not by the editor. (Kept the code in the example, unused.)
- `View` easing works differently now. Instead of `View` having `*_to` properties, it now only represents a specific viewport. You create two views, i.e. `view` and `view_to`, and call `view.easeTowards(view_to, smoothness)`
- `new Editor(world, view, canvas)` -> `new Editor(world, view, view_to, canvas)`
- `Mouse` no longer takes a `View` just to provide a silly helper function, so `new Mouse(canvas, view)` -> `new Mouse(canvas)`
- `mouse.toWorld()` is gone, so you can do `view.toWorld(mouse)` instead
- `mouse.endStep()` -> `mouse.resetForNextStep()`

## 0.0.0

- Just starting to extract this from [Tiamblia][],
published so I can start referencing this package in Tiamblia.
- Published as uncompiled CoffeeScript. So are any further versions until I mention otherwise.

[Tiamblia]: https://github.com/1j01/tiamblia-game
[Unreleased]: https://github.com/1j01/skele2d/compare/v0.0.10...HEAD
[0.0.10]: https://github.com/1j01/skele2d/compare/v0.0.9...v0.0.10
[0.0.9]: https://github.com/1j01/skele2d/compare/v0.0.8...v0.0.9
[0.0.8]: https://github.com/1j01/skele2d/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/1j01/skele2d/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/1j01/skele2d/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/1j01/skele2d/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/1j01/skele2d/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/1j01/skele2d/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/1j01/skele2d/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/1j01/skele2d/releases/tag/v0.0.1
