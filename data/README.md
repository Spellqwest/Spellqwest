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

## defs/
"Definitions" = raw descriptions of game content.
Put content here when you want to tune/balance/add content without touching code.

Subfolders:
- `enemies/` — enemy stats, archetypes, behaviors (as data references)
- `bosses/` — boss stats/phases as data
- `items/` — item definitions (name, rarity, tags, effects references)
- `item_sets/` — groups/collections for shops, pools, unlocks
- `spells/` — spell definitions (word, cost, damage, effect refs)
- `stages/` — stage metadata (biomes, enemy pools, boss list)
- `events/` — map events (shop, rest, treasure, story events)
- `map_nodes/` — node types & weights (combat/event/elite/etc.)
- `tutorials/` — tutorial step definitions (text, triggers, rules)

Format can be `.tres` (Godot Resources), `.json`, `.cfg`, etc. (Choose one approach and stick to it.Eins aussuchen und konsitent bleiben. Empfehle .tres)

## pools/
Weighted/random selection tables used for roguelike generation.
Examples:
- enemy spawn pools per stage
- loot tables
- shop inventory pools
- event roll tables
This keeps RNG tuning separate from the content definitions themselves.
