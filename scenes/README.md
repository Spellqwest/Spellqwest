# scenes/

This folder contains all Godot **scenes** (`.tscn`) and their supporting scene-level assets.
A "scene" is the layout/structure of nodes for screens, UI, entities, and reusable components.

Recommended organization:
- `app/` — root scenes like Boot/GameRoot (entry points, scene switching)
- `_shared/` — reusable scenes used by multiple systems (tooltips, modals, transitions, inventory widgets)
- `ui/` — UI scenes grouped by context (menu/map/combat) plus generic widgets
- `game/`— contains the game specific scenes (the ones below)
- `map/` — map screen, nodes, paths, and event screens
- `combat/` — combat screen, keyboard arena, spawners, enemies, projectiles
- `tutorial/` — tutorial screens/scenes (if you use them)

Guidelines:
- Keep scenes focused: one responsibility per scene when possible.
- Put code for scenes in `scripts/` (mirroring folder structure).
- `_shared/` is intentionally prefixed so it sorts to the top.
