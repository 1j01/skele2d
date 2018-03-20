# Skele2D

Skele2D is a game engine based around points, with a fancy in-game editor that you can integrate into your game
(...or that you might be able to, in the future.)

This project is pre-alpha. Consider it unreleased.

The core editor is basically done; you can select entities, drag them around, pose them, cut/copy and paste, et cetera.
The animation editor needs undo/redo, frame reordering, and maybe variable delays.
Undo/redo should be made efficient; currently it saves the entire world state every operation.

It's currently probably pretty limiting in terms of the strucure of your project,
if you don't copy the source code over and edit it and adapt it to your needs.

## Roadmap

* Finish separating this out into a reusable library / framework (from [Tiamblia](https://github.com/1j01/tiamblia-game))
	* Find a boundary between the engine and game, and think about how to make it not a problem
		* For instance, you might want the panning zooming view behavior in your actual game, so it'd be nice if that was separate from the editor
			* Hm, maybe that's not a good example because apparently it works like that if you simply don't handle view movement by focusing it on a player
	* Set up compilation (webpack or rollup)

* Finish up the animation editor's basic functionality

* Use this in a few games
