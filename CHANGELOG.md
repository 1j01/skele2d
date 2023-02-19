
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
<details>
	<summary>
		Changes in master that are not yet released.
		Click to see more.
	</summary>

Nothing here yet.

</details>

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
[Unreleased]: https://github.com/1j01/skele2d/compare/v0.0.9...HEAD
[0.0.9]: https://github.com/1j01/skele2d/compare/v0.0.8...v0.0.9
[0.0.8]: https://github.com/1j01/skele2d/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/1j01/skele2d/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/1j01/skele2d/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/1j01/skele2d/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/1j01/skele2d/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/1j01/skele2d/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/1j01/skele2d/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/1j01/skele2d/releases/tag/v0.0.1
