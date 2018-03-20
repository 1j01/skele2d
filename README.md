# Skele2D

Skele2D is a game engine based around points, with a fancy in-game editor that you can integrate into your game
(...or that you might be able to, in the future.)

This project is pre-alpha. Consider it unreleased.

## Features

* In-game editor where you can easily place and manipulate entities
* Animations, pose system lets you manipulate poses and compose poses and animations any way you want,
with tweening/interpolation helpers for cyclical and linear animations
* Pretty looking and professional UI

## State of Things

The core editor is basically done; you can select entities, drag them around, pose them, cut/copy and paste, et cetera.

The animation editor needs undo/redo, frame reordering, and maybe variable delays.

This engine is not yet fully separated out from [Tiamblia](https://github.com/1j01/tiamblia-game).  
It's not compiled into a library yet either (or set of libraries as it could end up being).

## Roadmap

* Finish separating this out into a reusable library / framework (from [Tiamblia](https://github.com/1j01/tiamblia-game))
	* Find a good boundary between the engine and game, and think about how to minimize assumptions and frameworkiness
		* For instance, you might want the panning zooming view behavior in your actual game, so it'd be nice if that was separate from the editor
			* Hm, maybe that's not a great example because apparently it works like that just fine if you simply don't handle view movement by centering it on a player or whatever
	* Set up compilation (webpack or rollup)
	* Get rid of ReactScript (an old library I made which is obsolete)
	* Update libraries

* Finish up the animation editor's basic functionality

* Undo/redo should be made efficient; currently it saves the entire world state every operation.

* Use this in a few games

## Demo

* Install [Node.js](https://nodejs.org/) if you don't have it.
* [Clone this repository](https://help.github.com/articles/cloning-a-repository/)
* In a command prompt / terminal, in the project directory, run `npm install && npm run install-example`
