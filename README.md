# Skele2D

Skele2D is a game engine based around points, with a fancy in-game editor.

There are lots of 2D game engines based around tiles; *this is the opposite of that.*
It's for games where the world is made of polygons, and the entities are made of points, connected by bones, in arbitrary configurations.

If there's a theme song for Skele2D, it's the one that goes:

> The hip bone's connected to the back bone  
> The back bone's connected to the neck bone…

This project is pre-alpha. **Consider it unreleased**.

<!-- TODO: add GIFs; also a logo would be good; maybe make a better demo that IS a logo -->


## Features

* In-game editor
  * Easily drag and drop to place entities in the world
  * Select entities, drag them around, and pose them (with double click)
  * Cut, copy and paste, undo and redo
  * Keyboard shortcuts and context menus
  * Zoom towards the mouse with mousewheel, and pan with middle mouse button
  * Animation editor
    * Shows previews of poses and animations, using the arbitrary drawing code of the entity
    * Create, rename, edit, and delete poses and animations
    * No undo/redo currently, but you can use Git for versioning
* Animations and poses can be blended together and composed any way you want (in code),
with tweening/interpolation helpers for both linear and cyclical animations
* Arbitrary data can be associated with points, for use with rendering, physics or whatever, for instance "color", "size", "velocity" - you name it!


## Demo

Check out [Tiamblia](https://1j01.github.io/tiamblia-game/)


## Setup / API

So far, if you wanted to use this, you'd have to look at the source code, and copy from the examples.

I do maintain a [changelog](CHANGELOG.md), so you wouldn't be too crazy to try and build a game with this,
but nothing's set in stone yet, and you probably want docs.

Right now you have to include Material UI in addition to the [module](https://www.npmjs.com/package/skele2d), as seen in the examples.

## Examples

* [`examples/webpack-coffee/`](examples/webpack-coffee/) - Webpack usage example, with CoffeeScript. This uses Webpack to bundle module imports (including Skele2D and other parts of the example), and coffee-loader to compile CoffeeScript.
* [`examples/script-tag-coffee/`](examples/script-tag-coffee/) - Script tag usage example, with CoffeeScript. This uses the in-browser CoffeeScript compiler, and uses globals instead of imports/exports.
<!-- * [`examples/esm/`](examples/esm/) - ES Modules example. This uses a separate ESM build of Skele2D, and imports it from inside a `<script type="module">`. -->
* [Tiamblia](https://github.com/1j01/tiamblia-game) - A game built with Skele2D (or a fuller example, at least.)

Both of the examples in this repo are super bare-bones, and don't actually show off all the entity types supported by the editor, only terrain — no posable or animated entities. (It was kind of an oversight when I was copying from Tiamblia and trimming it down.)

<!--
I'd also like to show off different things you can do with Skele2D, like:
* Using Skele2D with a physics engine, like Matter.js
* Using Skele2D with a rendering engine, like Pixi.js, or something that does textured polygons nicely. I'd want it to have a very different look, to show the breadth of what you can achieve.

Since I want to show off functionality distinct from module setups, I think I should pick a module setup, probably ESM (which I haven't done yet), for most of the examples to use, and then keep the other module setups super basic, just to show that it works with them.
In particular, I want to keep them to as few files as possible, to make it easier to maintain and understand them.
(I don't want to have a bunch of files that are named the same but in different directories that can get confused,
and can get out of sync with each other.)
I think I can bring most things into one or two files. ESM and script tag examples could be done in one HTML file,
but webpack might need a separate JS file (unless there's a plugin or option to make it operate on JS inlined in HTML,)
plus package.json and webpack.config.js
-->

## Dev Setup

Synopsis:
```bash
npm install
npm run build
npm run install-example
npm run example
```

This should run the webpack dev server for the webpack example, with hot module reloading.
You can open the example in your browser at http://localhost:8080/ or whatever port it gives you if that's taken.

### Webpack in Production

The webpack example can be built for production with:
```bash
cd examples/webpack-coffee
npm run build
```
Then the `examples/webpack-coffee` directory can be served with any web server, for instance:
```bash
python -m http.server
```
Then open http://localhost:8000 in your browser.

It could be deployed to a static site host, and some files could be excluded like the `node_modules` directory, `source` directory, `package.json`, `package-lock.json`, and `webpack.config.js`.

The examples in this repo are not yet deployed, but [Tiamblia](https://github.com/1j01/tiamblia-game) is [deployed to GitHub Pages here](https://1j01.github.io/tiamblia-game/), using a dumb Node.js script to copy only the files that are needed, and then the [gh-pages](https://www.npmjs.com/package/gh-pages) package to deploy.

### NW.js
The webpack example can also be run in NW.js, with:
```bash
npm run example-nw
```
When running in NW.js it automatically saves the `world.json` as you edit.
> Note: This workflow could be replaced by the FS Access API, which didn't exist when I made this originally.
> I don't think I'm terribly interested in NW.js for distributing games.
> It'll still be an _option_, of course, but it shouldn't be required for a nice workflow.

### Script Tag Example

The Script Tag example doesn't need pre-compiling in principle, but because it lives in this repo, it does reference `../../dist/skele2d.js`, which is built by the `npm run build` command.

Once the library is built, you can run the example with any web server, for instance:
```bash
npx live-server --open=examples/script-tag-coffee/
```
This will open the example in your browser, and automatically reload the page when you make changes to the source code.

Note: it will also reload when editing the library itself, but it won't reflect those changes until you run `npm run build` again. I could add an `--ignore`/`--ignorePattern` flag but I don't think it's worth it for this example, for now.

Also note: if you run a server at `examples/script-tag-coffee/`, it will try to request `skele2d.js` from outside the server root, which will fail.

(Would it be better to create a symlink, or copy the file to the example directory? That way it would be easer to copy the example as a base for a new project, as it would match more closely how you would include the library.)

### Troubleshooting

Any time you run into an error like `Module not found: Error: Can't resolve 'skele2d'`,
just run the following in the `examples/webpack-coffee` directory:
```bash
npm link skele2d
```
Or alternatively run `npm run install-example` again.

This can happen when updating dependencies, or (perhaps) when switching branches, or when you've just cloned the repo and haven't run the [installation procedure](#dev-setup) yet.

## Roadmap

* Finish separating this out into a reusable library / framework (from [Tiamblia](https://github.com/1j01/tiamblia-game))
	* Find a good boundary between the engine and game, and think about how to minimize assumptions
		* When something is part of an application/game, there aren't necessarily any barriers between it and the application/game code, which can make it easy to introduce coupling, which is bad, but importantly, there are no barriers to editing any part of it, which is really nice: you can adapt it to your needs as your needs progress. When you go to separate it out into a library, suddenly you're confronted with either having to remove all the coupling (which takes significant effort and thought), or just sort of "include everything" and make it a grab-bag framework with all the functionality you need for each applications you intend to use it with - which is of course, bad. Or somewhere in between, or whatever.
			* OOP introduces problems with reusability, with its methods on classes/objects. Also if you have any private variables.
		* Try to remove the prescribed `Entity` class (currently relied upon: `x`, `y`, `structure`, `toWorld`, `fromWorld`, and serialization)
		* Ditto for `World` (currently relied upon for serialization, and directly accessing `entities`)
		* Look into [ResurrectJS](https://github.com/skeeto/resurrect-js) for serialization (I'd come across [cereal](https://github.com/atomizejs/cereal) before, but it doesn't handle prototypes); let's see, there's also [kaiser](https://www.npmjs.com/package/kaiser), and a few others
			* I did make a system for serializing and deserializing references to other entities, but it only supports references to other entities as top level properties of an entity, because that's all I needed - the player can hold a bow, and an arrow, but for instance if you wanted to have an array of references to other entities (perhaps multiple arrows!), it wouldn't work. I don't think it would actually be that hard to extend it to arbitrarily nested properties, but it would certainly be nice to offload that work and complexity to a library.
		* Separate out world saving/loading logic (you could want to save to and load from a file like I have it now in NW.js, or over the network to a server (Node, Python, PHP, whatever), or to localStorage, IndexedDB, whatever)
	* Get rid of [ReactScript](https://github.com/1j01/react-script) (an old library I made, deprecated) in favor of JSX in CoffeeScript 2 (requires a JSX compilation step!)
	* Documentation!
		* Setup
		* API
		* For now, it is very much a framework, so document how to stay within the bounds of it, and conventions that make it a smoother experience
			* References to other entities must be at the top level for now
			* Adding data to other entities currently works, but the entity data might be versioned later and not accept extra data (or it might be that you can easily allow exceptions,) but/so it might be better to store extra data within an entity relating to other entities, like a key value store with the keys as entity IDs (but that's not fun) (using entity references as keys could be a *little* bit fun, but overall the paradigm wouldn't be)
			* When animations/poses don't exist, default to `@structure.getPose()`
			* Name points and segments like how you'd name properties, so you can access them as such when drawing/stepping (e.g. `let {leftArm, rightArm} = @structure.points`)
			* A default pose is decided by the (overridable) method `initLayout`, and if you use "left"/"right" in the names of points it moves them to the left or right, and it uses poses named "Default"/"Stand"/"Standing"/"Idle" in that order (most to least preferred), if one is available.
		* Demos:
			* Improve the simple example, maybe make a logo as part of it
			* Could make a better version of [pbp2d](https://github.com/1j01/pbp2d), a point based physics sandbox; or a full blown physics engine playground; rigid bodies use polygons and polygons use points too, and generating shapes and bodies from other types of structures would be very much possible too
			* Could do a demo with a totally different renderer, overriding `Editor.draw` and maybe `View`. Three.js could be fun :)

* Versioning of world data
	* Code patterns for upgrading [can be pretty simple](https://github.com/1j01/wavey/blob/12203a2166c27aab783592184263dbb2daad0e44/src/components/AudioEditor.coffee#L88-L128)

* Add <kbd>shift</kbd>/<kbd>ctrl</kbd> selection-manipulation modifiers

* Add <kbd>alt</kbd>+drag to drag the selection from anywhere (i.e. without having to have your mouse over part of the selection, especially for when the selection is a set of points) (inspired by [this video](https://youtu.be/elws59R9CrM))

* Make current "sculpt mode" available as a tool for both polygon structures and bone structures

* Add additive and subtractive brush tools for polygon structures (terrain)

* Add undo/redo, frame reordering, and maybe variable delays to the animation editor

* Make undo/redo efficient (currently it saves the entire world state every operation!)

* Use this in a few different games

* It would be nice to have vector maths, haha! Kinda silly how this whole thing is based around points and there's no vector operations
	* We want to keep (the ability to keep) arbitrary data on (or at least associated with) points


## Changelog

See [CHANGELOG.md](CHANGELOG.md)

## License

Open source under the [MIT License](LICENSE.txt)
