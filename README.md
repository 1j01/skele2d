# Skele2D

Skele2D is a game engine based around points, with a fancy in-game editor.

This project is pre-alpha. Consider it **unreleased**.

<!-- TODO: add GIFs; also a logo would be good -->

## Features

* Animation & pose system lets you manipulate and compose poses and animations any way you want,
with tweening/interpolation helpers for cyclical and linear animations
* In-game editor where you can easily place and manipulate entities
* Pretty looking and professional UI
* Entity previews and previews of animations and animation frames, shown with *your* arbitrary drawing code
* You can select entities, drag them around, pose them, cut, copy and paste, undo and redo
* Both keyboard shortcuts *and* context menus!
* Arbitrary data can be associated with / tacked onto points, for use with rendering, physics or whatever, for instance "color", "size", "velocity" - you name it!

## Roadmap

* Finish separating this out into a reusable library / framework (from [Tiamblia][])
	* Find a good boundary between the engine and game, and think about how to minimize assumptions
		* When something is part of an application/game, there aren't necessesarily any barriers between it and the application/game code, which can make it easy to introduce coupling, which is bad, but importantly, there are no barriers to editing any part of it, which is really nice: you can adapt it to your needs as your needs progress. When you go to separate it out into a library, suddenly you're confronted with either having to remove all the coupling (which takes significant effort and thought), or just sort of "include everything" and make it a grab-bag framework with all the functionality you need for each applications you intend to use it with - which is of course, bad. Or somewhere in between, or whatever.
			* OOP introduces problems with reusability, with its methods on classes/objects. Also if you have any private variables.
		* Try to remove the proscribed `Entity` class (currently relied upon: `x`, `y`, `structure`, `toWorld`, `fromWorld`, and serialization)
		* Ditto for `World` (currently relied upon for serialization, and directly accessing `entities`)
		* Look into [ResurrectJS](https://github.com/skeeto/resurrect-js) for serialization (I'd come across [cereal](https://github.com/atomizejs/cereal) before, but it doesn't handle prototypes); let's see, there's also [kaiser](https://www.npmjs.com/package/kaiser), and a few others
			* I did make a system for serializing and deserializing references to other entities, but it only supports references to other entities as top level properties of an entity, because that's all I needed - the player can hold a bow, and an arrow, but for instance if you wanted to have an array of references to other entities (perhaps multiple arrows!), it wouldn't work. I don't think it would actually be that hard to extend it to arbitrarily nested properties, but it would certainly be nice to offload that work and complexity to a library.
		* Separate out world saving/loading logic (you could want to save to and load from a file like I have it now in NW.js, or over the network to a server (Node, Python, PHP, whatever), or to localStorage, IndexedDB, whatever)
		* Make context menus work without NW.js (could also support Electron natively)
	* Get rid of [ReactScript](https://github.com/1j01/react-script) (an old library I made which is deprecated) in favor of JSX in CoffeeScript 2 (requires a JSX compilation step!)
	* Documentation!
		* Setup
		* API
		* Document things like `initLayout`'s heuristics based on names of points containing "left"/"right", and special casing the default pose if there's "Default"/"Stand"/"Standing"/"Idle" available
		* Demos or it didn't happen!
			* Improve the one demo (maybe make a logo as part of it)
			* Could do a demo with a totally different renderer, overriding `Editor.draw` and maybe `View`. Three.js could be fun :)

* Add <kbd>shift</kbd>/<kbd>ctrl</kbd> selection-manipulation modifiers

* Add <kbd>alt</kbd>+drag to drag the selection from anywhere (i.e. without having to have your mouse over part of the selection, especially for when the selection is a set of points) (inspired by [this video](https://youtu.be/elws59R9CrM))

* Add undo/redo, frame reordering, and maybe variable delays to the animation editor

* Make undo/redo efficient (currently it saves the entire world state every operation!)

* Use this in a few different games

## Demo

The demo is really lame at the moment; there are no entities to animate!
See [Tiamblia][] for a better demo.

* Install [Node.js](https://nodejs.org/) if you don't have it.
* [Clone this repository](https://help.github.com/articles/cloning-a-repository/)
* In a command prompt / terminal, in the project directory, run `npm install && npm run install-example`
* Then to run the demo, from now on you can just do `npm run example`

### Better Demo

Clone [Tiamblia][] instead, `npm i` to install, and `npm start` to run

## Changelog

The software is essentially unreleased, but I thought I might as well get in a habit of doing a changelog.

See [CHANGELOG.md](CHANGELOG.md)

Hey look it's not actually that hard. You already have commit history, so it's just a matter of presenting that information to users (theoretical users in this case - heh, maybe that helps), highlighting API changes.

[Tiamblia]: https://github.com/1j01/tiamblia-game
