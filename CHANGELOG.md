
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

- Redos are now restored when you try to delete a point that an entity needs to render.
  As far as the editing paradigm is concerned, you haven't made a change because it wasn't allowed.

</details>

## v0.0.7

- Minification is enabled
- Internally, switched to ES module syntax
- Changes to webpack configuration may fix `Uncaught TypeError: Class extends value undefined is not a constructor or null`

## v0.0.6

- CoffeeScript source files are no longer published
- The module is now published as a compiled bundle, and so you no longer need a complex Webpack setup to use it
- Classes are exported from `require("skele2d")` (`Entity`, `Terrain`, `Mouse`, etc.)
- Helpers are exported at `require("skele2d").helpers`
- `addEntityClass` is moved out of helpers, so it's at `require("skele2d").addEntityClass`
- `entity_classes` is moved out of helpers and renamed, so it's at `require("skele2d").entityClasses`
- `rename_object_key` is removed as it was only intended for internal use by the editor

## v0.0.5

- Context menus are now supported in browser, not just in NW.js
    - (NW.js retains *native* context menus)
- Sculpt mode is more useful
    - Correctly saves after each gesture
    - Pushes points in the direction you move the mouse, rather than just away from the mouse, which was a temporary (and rather unpleasant and useless) implementation

## v0.0.4

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
