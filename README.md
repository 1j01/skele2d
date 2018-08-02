# Skele2D

Skele2D is a game engine based around points, with a fancy in-game editor.

This project is pre-alpha. **Consider it unreleased**.

<!-- TODO: add GIFs; also a logo would be good -->


## Features

* Animation & pose system lets you manipulate and compose poses and animations any way you want,
with tweening/interpolation helpers for cyclical and linear animations
* In-game editor where you can easily place and manipulate entities
* Pretty looking and professional UI
* Entity previews and previews of animations and animation frames, shown with *your* arbitrary drawing code
* You can select entities, drag them around, pose them, cut, copy and paste, undo and redo
* Both keyboard shortcuts *and* context menus!
* Arbitrary data can be associated with / tacked onto points, for use with rendering, physics or whatever, for instance "color", "size", "velocity" - you name it! (*literally*, of course)


## Demo

The demo is really lame at the moment; there are no entities to animate!
See [Tiamblia][] for a better demo.

* Install [Node.js](https://nodejs.org/) if you don't have it.
* [Clone this repository](https://help.github.com/articles/cloning-a-repository/)
* In a command prompt / terminal, in the project directory, run `npm install && npm run install-example`
* Then to run the demo, from now on you can just do `npm run example`

### Better Demo

Clone [Tiamblia][] instead, `npm i` to install, and `npm start` to run


## Setup / API

So far, if you wanted to use this, you'd have to look at the source code, and copy from the examples.

I wouldn't recommend using this yet!

Right now the [module](https://www.npmjs.com/package/skele2d) is published as CoffeeScript source files
and you have to include other stuff like Material UI, and setup Webpack with CoffeeScript support as seen in [`example/index.html`](example/index.html) and [`example/webpack.config.js`](example/webpack.config.js)


## Roadmap

* Finish separating this out into a reusable library / framework (from [Tiamblia][])
	* Find a good boundary between the engine and game, and think about how to minimize assumptions
		* When something is part of an application/game, there aren't necessarily any barriers between it and the application/game code, which can make it easy to introduce coupling, which is bad, but importantly, there are no barriers to editing any part of it, which is really nice: you can adapt it to your needs as your needs progress. When you go to separate it out into a library, suddenly you're confronted with either having to remove all the coupling (which takes significant effort and thought), or just sort of "include everything" and make it a grab-bag framework with all the functionality you need for each applications you intend to use it with - which is of course, bad. Or somewhere in between, or whatever.
			* OOP introduces problems with reusability, with its methods on classes/objects. Also if you have any private variables.
		* Try to remove the proscribed `Entity` class (currently relied upon: `x`, `y`, `structure`, `toWorld`, `fromWorld`, and serialization)
		* Ditto for `World` (currently relied upon for serialization, and directly accessing `entities`)
		* Look into [ResurrectJS](https://github.com/skeeto/resurrect-js) for serialization (I'd come across [cereal](https://github.com/atomizejs/cereal) before, but it doesn't handle prototypes); let's see, there's also [kaiser](https://www.npmjs.com/package/kaiser), and a few others
			* I did make a system for serializing and deserializing references to other entities, but it only supports references to other entities as top level properties of an entity, because that's all I needed - the player can hold a bow, and an arrow, but for instance if you wanted to have an array of references to other entities (perhaps multiple arrows!), it wouldn't work. I don't think it would actually be that hard to extend it to arbitrarily nested properties, but it would certainly be nice to offload that work and complexity to a library.
		* Separate out world saving/loading logic (you could want to save to and load from a file like I have it now in NW.js, or over the network to a server (Node, Python, PHP, whatever), or to localStorage, IndexedDB, whatever)
		* Make context menus work without NW.js (could also support Electron natively)
	* Get rid of [ReactScript](https://github.com/1j01/react-script) (an old library I made, deprecated) in favor of JSX in CoffeeScript 2 (requires a JSX compilation step!)
	* Documentation!
		* Setup
		* API
		* For now, it is very much a framework, so document how to stay within the bounds of it, and conventions that make it a smoother experience
			* References to other entities must be at the top level for now
			* Adding data to other entities currently works, but the entity data might be versioned later and not accept extra data (or it might be that you can easily allow exceptions,) but/so it might be better to store extra data within an entity relating to other entities, like a key value store with the keys as entity IDs (but that's not fun) (using entity references as keys could be a *little* bit fun, but overal the paradigm wouldn't be)
			* When animations/poses don't exist, default to `@structure.getPose()`
			* Name points and segments like how you'd name properties, so you can access them as such when drawing/stepping (e.g. `let {leftArm, rightArm} = @structure.points`)
			* A default pose is decided by the (overridable) method `initLayout`, and if you use "left"/"right" in the names of points it moves them to the left or right, and it uses poses named "Default"/"Stand"/"Standing"/"Idle" in that order (most to least preferred), if one is available.
		* Demos or it didn't happen!
			* Deploy to the web; it's actually already set up to use `localStorage` (in place of `fs`) and such, and XHR to load the existing world data and animation data
			* Improve the one demo (maybe make a logo as part of it)
			* Could make a better version of [pbp2d](https://github.com/1j01/pbp2d), a point based physics sandbox; or a full blown physics engine playground; rigid bodies use polygons and polygons use points too, and generating shapes and bodies from other types of structures would be very much possible too
			* Could do a demo with a totally different renderer, overriding `Editor.draw` and maybe `View`. Three.js could be fun :)

* Versioning of world data
	* Code patterns for upgrading [can be pretty simple](https://github.com/1j01/wavey/blob/12203a2166c27aab783592184263dbb2daad0e44/src/components/AudioEditor.coffee#L88-L128)

* Add <kbd>shift</kbd>/<kbd>ctrl</kbd> selection-manipulation modifiers

* Add <kbd>alt</kbd>+drag to drag the selection from anywhere (i.e. without having to have your mouse over part of the selection, especially for when the selection is a set of points) (inspired by [this video](https://youtu.be/elws59R9CrM))

* Add undo/redo, frame reordering, and maybe variable delays to the animation editor

* Make undo/redo efficient (currently it saves the entire world state every operation!)

* Use this in a few different games

* It would be nice to have vector maths, haha! Kinda silly how this whole thing is based around points and there's no vector operations
	* We want to keep (the ability to keep) arbitrary data on (or at least associated with) points


## Changelog

The software is essentially unreleased, but I thought I might as well get in a habit of doing a changelog.

See [CHANGELOG.md](CHANGELOG.md)

Hey look it's not actually that hard. You already have commit history, so it's just a matter of presenting that information to users (theoretical users in this case... heh, maybe that helps), highlighting API changes.


[Tiamblia]: https://github.com/1j01/tiamblia-game
