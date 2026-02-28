# resources/

This folder contains Godot **Resource** assets that represent structured game data.
Resources are great when you want:
- typed fields
- editor-friendly editing
- easy referencing from scenes and scripts

Typical contents:
- item resources (base item types, rarities, affixes)
- spell resources
- enemy/boss resources (if not using external defs)
- status effects / modifiers
- UI themes (Theme resources, StyleBoxes, fonts as resources)
- reusable data objects used by systems (RNG settings, tuning curves, etc.)

Guidelines:
- Prefer `resources/` for data you want to reference directly in the editor.
- Avoid putting gameplay scenes (`.tscn`) here; those belong in `scenes/`.

Vielleicht packen wir data/defs auch einfach direkt in die resources?
