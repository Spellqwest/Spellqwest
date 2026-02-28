# data/

This folder contains **data and configuration** for the game: definitions, pools, save files, and defaults.
Just simple files that describe game content (enemies, items, spells, etc.). They only contain data (numbers, names, properties), no logic.
Nothing here should be a .tscn . Scripts allowed only if they are *data loaders or validators*.

## configs/
Project-wide configuration defaults.
Examples:
- default settings values
- default keybinds
- audio volume defaults
Used to copy into the player's settings.

## runs/ (idk ob in scope, aber wär cool)
Save data for runs and profiles.
Examples:
- save slots
- run state snapshots
- meta progression saves (falls wir zu dem Punkt kommen)

## pools/
Weighted/random selection tables used for roguelike generation.
Examples:
- enemy spawn pools per stage
- loot tables
- shop inventory pools
- event roll tables
This keeps RNG tuning separate from the content definitions themselves.
